#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
validate_sql_new.py
===================
校验 docs/sql_new/（已修复版）与 docs/sql/（基线）的关系与自身一致性。

校验分三层：
  A. 血缘：基线 34 个输入文件的 sha256 与 manifest.json 一致 → 证明基线未被修改。
  B. 修复：89 表排序规则覆盖、8 处 BIGINT 对齐、4 处 COMMENT、
            61 条推断外键类型不兼容数归零、编号文件与 migrations 镜像一致。
  C. 可执行性：MySQL 便携子集转换后在 SQLite 真实建表（仅 DDL，不执行业务 INSERT）、
                INSERT 行数、13 索引列存在性与 up/down 对称、静态 lint。

明确边界：SQLite 便携子集通过 != MySQL 8.0 认证。本机无 mysql/mysqld，
未做 InnoDB 外键创建、EXPLAIN、锁竞争、QPS、复制与 HA 切换验证。
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import sqlite3
from pathlib import Path

NUMBERED = [
    "01_init_databases.sql", "02_user.sql", "03_catalog.sql", "04_ticket_inventory.sql",
    "05_order.sql", "06_payment.sql", "07_marketing.sql", "08_community.sql",
    "09_content_ops.sql", "10_dict_enums.sql", "11_rev_evidence.sql", "12_constraints.sql",
]
DB_HINT = {
    "02_user.sql": "planstar_user", "03_catalog.sql": "planstar_catalog",
    "04_ticket_inventory.sql": "planstar_ticket", "05_order.sql": "planstar_order",
    "06_payment.sql": "planstar_payment", "07_marketing.sql": "planstar_marketing",
    "08_community.sql": "planstar_community", "09_content_ops.sql": "planstar_content",
    "10_dict_enums.sql": "planstar_meta", "11_rev_evidence.sql": "planstar_meta",
}
TYPE_FIXES = [
    ("03_catalog.sql", "activity_events", "ticket_group_id"),
    ("04_ticket_inventory.sql", "ticket_groups", "pin_tuan_campaign_item_id"),
    ("05_order.sql", "orders", "pin_tuan_id"),
    ("05_order.sql", "speed_packs", "pin_tuan_id"),
    ("07_marketing.sql", "coupons", "activity_event_id"),
    ("07_marketing.sql", "pin_tuan_campaigns", "shop_id"),
    ("07_marketing.sql", "pin_tuan_orders", "pin_tuan_id"),
    ("07_marketing.sql", "pin_tuan_orders", "pin_tuan_campaign_item_id"),
]
COMMENT_FIXES = [
    ("10_dict_enums.sql", "dict_enums"),
    ("11_rev_evidence.sql", "_rev_dto_field_catalog"),
    ("11_rev_evidence.sql", "_rev_endpoint_catalog"),
    ("11_rev_evidence.sql", "_rev_dto_table_mapping"),
]
EXPECTED_INSERTS = {
    "dict_enums": 143,
    "_rev_dto_field_catalog": 1736,
    "_rev_endpoint_catalog": 267,
    "_rev_dto_table_mapping": 217,
}
TABLE_RE = re.compile(r"^CREATE TABLE IF NOT EXISTS `([^`]+)` \(")
TAIL_RE = re.compile(r"^\) ENGINE")
COL_RE = re.compile(r"^\s*`([^`]+)`\s+([A-Za-z]+(?:\([^)]*\))?)")
FK_RE = re.compile(
    r"ALTER TABLE `([^`]+)`\.`([^`]+)` ADD CONSTRAINT `([^`]+)` "
    r"FOREIGN KEY \(`([^`]+)`\) REFERENCES `([^`]+)`\.`([^`]+)` \(`([^`]+)`\);"
)
ADD_INDEX_RE = re.compile(
    r"ALTER TABLE `([^`]+)`\.`([^`]+)` ADD INDEX `([^`]+)` \(([^)]*)\);"
)
DROP_INDEX_RE = re.compile(r"ALTER TABLE `[^`]+`\.`[^`]+` DROP INDEX `([^`]+)`;")
INT_TYPES = {"TINYINT", "SMALLINT", "MEDIUMINT", "INT", "BIGINT"}


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def base_type(t: str) -> str:
    m = re.match(r"([A-Za-z]+)", t.upper().strip())
    return m.group(1) if m else t.upper().strip()


def fk_compatible(child: str, parent: str) -> bool:
    cb, pb = base_type(child), base_type(parent)
    if cb in INT_TYPES and pb in INT_TYPES:
        return cb == pb  # MySQL 要求整数 size/sign 一致
    return cb == pb  # 字符类型长度可不同，但 charset/collation 必须一致（R1 已统一）


def parse_columns(out: Path) -> dict:
    cols = {}
    for fname, db in DB_HINT.items():
        cur = None
        for line in read(out / fname).splitlines():
            s = line.strip()
            m = TABLE_RE.match(s)
            if m:
                cur = m.group(1)
                continue
            if TAIL_RE.match(s):
                cur = None
                continue
            if cur is None:
                continue
            c = COL_RE.match(s)
            if c:
                cols[(db, cur, c.group(1))] = c.group(2)
    return cols


def count_insert_rows(text: str) -> dict:
    counts, cur = {}, None
    for line in text.splitlines():
        s = line.strip()
        m = re.match(r"INSERT INTO `([^`]+)`", s)
        if m:
            cur = m.group(1)
            counts.setdefault(cur, 0)
            continue
        if cur and s.startswith("("):
            counts[cur] += 1
        if cur and s.endswith(";"):
            cur = None
    return counts


def sql_body(text: str) -> list[str]:
    out = []
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("--") or s.startswith("USE `") or s.startswith("SET "):
            continue
        out.append(s)
    return out


def to_sqlite_ddl(text: str) -> str:
    """只保留 CREATE TABLE 的便携子集：去掉 COMMENT / AUTO_INCREMENT / 内联 KEY / 表尾 ENGINE。"""
    result, cur = [], None
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("--") or s.startswith("USE `") or s.startswith("CREATE DATABASE") or s.startswith("SET "):
            continue
        if TABLE_RE.match(s):
            cur = [s]
            continue
        if cur is not None:
            if TAIL_RE.match(s):
                body = []
                for b in cur[1:]:
                    if re.match(r"^(UNIQUE\s+)?(KEY|INDEX)\s+`", b) or b.startswith("CONSTRAINT "):
                        continue
                    b = re.sub(r"\s+COMMENT\s+'(?:[^']|'')*'", "", b)
                    b = re.sub(r"\s+AUTO_INCREMENT\b", "", b)
                    body.append(b)
                if body:
                    last = body[-1].rstrip()
                    while last.endswith(","):
                        last = last[:-1].rstrip()
                    body[-1] = last
                result.append(cur[0])
                result.extend(body)
                result.append(");")
                cur = None
            else:
                cur.append(s)
    return "\n".join(result)


def strip_comments(text: str) -> str:
    return "\n".join(l for l in text.splitlines() if not l.strip().startswith("--"))


def main() -> None:
    here = Path(__file__).resolve().parent
    ap = argparse.ArgumentParser()
    ap.add_argument("--baseline", default=str(here.parent.parent / "sql"))
    ap.add_argument("--out", default=str(here.parent))
    args = ap.parse_args()
    baseline, out = Path(args.baseline).resolve(), Path(args.out).resolve()

    checks: list[dict] = []
    details: dict = {}

    def check(name: str, ok: bool, detail: str) -> None:
        checks.append({"name": name, "ok": bool(ok), "detail": detail})

    manifest = json.loads(read(out / "manifest.json"))
    expected_hashes = manifest["baseline_sha256"]

    # A. 血缘
    mismatches = []
    for rel, digest in expected_hashes.items():
        p = baseline / rel
        if not p.exists() or sha256(p) != digest:
            mismatches.append(rel)
    check("A1 基线 docs/sql 未被修改（34 个输入文件 sha256）", not mismatches,
          "全部一致" if not mismatches else f"不一致: {mismatches}")
    details["baseline_files_checked"] = len(expected_hashes)

    texts = {f: read(out / f) for f in NUMBERED}

    # B1. 表数量 + 排序规则覆盖
    tables, tails, tails_missing = [], [], []
    for f, db in DB_HINT.items():
        for line in texts[f].splitlines():
            s = line.strip()
            if TABLE_RE.match(s):
                tables.append((db, TABLE_RE.match(s).group(1)))
            if TAIL_RE.match(s):
                tails.append(s)
                if "COLLATE=utf8mb4_unicode_ci" not in s:
                    tails_missing.append((f, s))
    check("B1 89 张表 + 表尾全部显式 COLLATE", len(tables) == 89 and len(tails) == 89 and not tails_missing,
          f"tables={len(tables)} tails={len(tails)} missing={len(tails_missing)}")
    legacy = sum(1 for t in texts.values() if ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT=" in t)
    check("B2 无残留「无 COLLATE」表尾", legacy == 0, f"legacy tails={legacy}")
    details["table_count"] = len(tables)
    details["collate_tails"] = len(tails)

    # B2. R2 类型对齐
    cols = parse_columns(out)
    r2_bad = []
    for f, tbl, col in TYPE_FIXES:
        typ = cols.get((DB_HINT[f], tbl, col))
        if typ is None or base_type(typ) != "BIGINT":
            r2_bad.append(f"{f}/{tbl}.{col}={typ}")
    check("B3 8 处关联 ID 全部 BIGINT", not r2_bad,
          "8/8 BIGINT" if not r2_bad else "; ".join(r2_bad))
    details["r2_aligned"] = 8 - len(r2_bad)

    # B3. R3 注释
    r3_bad = []
    for f, tbl in COMMENT_FIXES:
        block, inside = [], False
        for line in texts[f].splitlines():
            s = line.strip()
            if TABLE_RE.match(s):
                inside = (TABLE_RE.match(s).group(1) == tbl)
            if inside:
                block.append(s)
            if inside and TAIL_RE.match(s):
                inside = False
        if not any(l.startswith("`id` INT NOT NULL AUTO_INCREMENT") and "COMMENT" in l for l in block):
            r3_bad.append(f"{f}/{tbl}.id")
    check("B4 4 处元数据代理主键已补 COMMENT", not r3_bad,
          "4/4" if not r3_bad else "; ".join(r3_bad))
    details["r3_commented"] = 4 - len(r3_bad)

    # B4. 61 条外键类型兼容
    fks = FK_RE.findall(texts["12_constraints.sql"])
    incompatible, missing = [], []
    for cdb, ctbl, name, ccol, pdb, ptbl, pcol in fks:
        ct, pt = cols.get((cdb, ctbl, ccol)), cols.get((pdb, ptbl, pcol))
        if ct is None or pt is None:
            missing.append(f"{name}: {ct}/{pt}")
        elif not fk_compatible(ct, pt):
            incompatible.append({"name": name, "child": f"{cdb}.{ctbl}.{ccol}", "child_type": ct,
                                 "parent": f"{pdb}.{ptbl}.{pcol}", "parent_type": pt})
    check("B5 61 条推断外键类型不兼容数归零", len(fks) == 61 and not incompatible and not missing,
          f"fk={len(fks)} incompatible={len(incompatible)} missing={len(missing)}")
    details["fk_count"] = len(fks)
    details["fk_incompatible"] = incompatible
    details["fk_missing_columns"] = missing

    # B5. 编号文件与 migrations 镜像一致
    body_by_db = {}
    for f in DB_HINT:
        body_by_db.setdefault(DB_HINT[f], []).extend(sql_body(texts[f]))
    mig_issues, order_only = [], []
    for db, expected in body_by_db.items():
        up = out / "migrations" / db / "000001_init.up.sql"
        if not up.exists():
            mig_issues.append(f"{db}: missing up")
            continue
        actual = sql_body(read(up))
        if actual == expected:
            continue
        # planstar_meta 由 10+11 两个编号文件合并，基线生成器把证据表 DDL 提前，
        # 语句顺序与编号文件拼接不同；只要内容多重集完全相同即视为一致。
        if sorted(actual) == sorted(expected):
            order_only.append(db)
            continue
        a, b = expected, actual
        sa, sb = set(a), set(b)
        mig_issues.append(f"{db}: 内容不一致 (numbered={len(a)} mig={len(b)}, "
                          f"only_numbered={len(sa - sb)}, only_mig={len(sb - sa)})")
    check("B6 编号文件与 9 组 migrations up 内容一致", not mig_issues,
          f"9/9 一致（其中 {len(order_only)} 个库仅语句顺序不同: {', '.join(order_only) or '无'}）"
          if not mig_issues else "; ".join(mig_issues))
    details["migrations_checked"] = len(body_by_db)
    details["migrations_order_only"] = order_only

    # B6. INSERT 行数
    insert_counts = {}
    for f in ("10_dict_enums.sql", "11_rev_evidence.sql"):
        insert_counts.update(count_insert_rows(texts[f]))
    insert_bad = [f"{k}: {insert_counts.get(k)} != {v}" for k, v in EXPECTED_INSERTS.items()
                  if insert_counts.get(k) != v]
    check("B7 字典/证据 INSERT 行数（143/1736/267/217）", not insert_bad,
          json.dumps(insert_counts, ensure_ascii=False) if not insert_bad else "; ".join(insert_bad))
    details["insert_rows"] = insert_counts

    # C1. 静态 lint
    lint = []
    for f, t in texts.items():
        if t.count("`") % 2:
            lint.append(f"{f}: 反引号不平衡")
        exec_body = strip_comments(t)
        if f != "12_constraints.sql" and re.search(r"\b(DROP\s+TABLE|DELETE\s+FROM|TRUNCATE)\b", exec_body, re.I):
            lint.append(f"{f}: 含破坏性语句")
    proposals = strip_comments(read(out / "optional" / "PROPOSALS.sql")).strip()
    if proposals:
        lint.append("optional/PROPOSALS.sql 含可执行语句")
    drop_fk = len(re.findall(r"DROP FOREIGN KEY", read(out / "optional" / "drop_optional_fks.sql")))
    if drop_fk != 61:
        lint.append(f"drop_optional_fks.sql: {drop_fk} != 61")
    check("C1 静态 lint（反引号/破坏性语句/提案零语句/61 条 FK 删除）", not lint,
          "0 issue" if not lint else "; ".join(lint))

    # C2. 13 索引列存在性 + up/down 对称
    up13, down13 = read(out / "13_query_indexes.sql"), read(out / "13_query_indexes.down.sql")
    add_idx = ADD_INDEX_RE.findall(up13)
    idx_issues = []
    for db, tbl, name, colstr in add_idx:
        for c in re.findall(r"`([^`]+)`", colstr):
            if (db, tbl, c) not in cols:
                idx_issues.append(f"{name}: 列 {db}.{tbl}.{c} 不存在")
    add_names = {n for _, _, n, _ in add_idx}
    drop_names = set(DROP_INDEX_RE.findall(down13))
    down_add_names = {n for _, _, n, _ in ADD_INDEX_RE.findall(down13)}
    symmetric = add_names - drop_names <= set() and down_add_names <= {"idx_feed_addtime"}
    if not symmetric:
        idx_issues.append(f"up/down 索引名不对称: add={sorted(add_names)} down_drop={sorted(drop_names)}")
    check("C2 13 索引列存在 + up/down 对称", not idx_issues and len(add_idx) == 8,
          f"add={len(add_idx)} 列全部存在" if not idx_issues else "; ".join(idx_issues))
    details["index_candidates"] = len(add_idx)

    # C3. SQLite 便携子集真实建表
    sqlite_error, sqlite_tables = None, 0
    try:
        conn = sqlite3.connect(":memory:")
        conn.execute("PRAGMA foreign_keys = ON")
        ddl = "\n".join(to_sqlite_ddl(texts[f]) for f in DB_HINT)
        conn.executescript(ddl)
        sqlite_tables = conn.execute(
            "SELECT count(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
        ).fetchone()[0]
        conn.close()
    except Exception as exc:  # noqa: BLE001
        sqlite_error = f"{type(exc).__name__}: {exc}"
    check("C3 SQLite 便携子集真实建表（仅 DDL）", sqlite_error is None and sqlite_tables == 89,
          f"tables={sqlite_tables}" if not sqlite_error else sqlite_error)
    details["sqlite_tables"] = sqlite_tables
    details["sqlite_error"] = sqlite_error

    # C4. 从基线精确重放修复，逐字节证明「除已声明修复外零改动」
    spec = importlib.util.spec_from_file_location("build_sql_new", out / "tools" / "build_sql_new.py")
    bs = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(bs)
    replay_issues = []
    for name in NUMBERED:
        b = read(baseline / name)
        if name in ("01_init_databases.sql", "12_constraints.sql"):
            expected = bs.HEADER.format(name=name) + "\n" + b
            if name == "12_constraints.sql":
                expected = expected.replace(bs.CONSTRAINT_NEEDLE,
                                            bs.CONSTRAINT_NOTE + bs.CONSTRAINT_NEEDLE, 1)
        else:
            expected = bs.HEADER.format(name=name) + "\n" + bs.transform(b, name)[0]
        if texts[name] != expected:
            replay_issues.append(name)
    mig_root = baseline / "migrations"
    for f in sorted(mig_root.rglob("*.sql")):
        rel = f.relative_to(mig_root)
        label = str(rel).replace("\\", "/")
        b = read(f)
        expected = bs.HEADER.format(name=label) + "\n" + (
            bs.transform(b, None)[0] if f.name.endswith(".up.sql") else b
        )
        if read(out / "migrations" / rel) != expected:
            replay_issues.append(label)
    check("C4 零额外改动：从基线精确重放后逐字节一致（12 编号 + 18 migrations）",
          not replay_issues,
          f"{len(NUMBERED) + 18} 个文件全部一致" if not replay_issues else "; ".join(replay_issues[:8]))
    details["replay_files_checked"] = len(NUMBERED) + 18

    status = "PASS" if all(c["ok"] for c in checks) else "FAIL"
    result = {"status": status, "checks": checks, "details": details,
              "scope_note": "SQLite 便携子集仅验证 DDL 可执行；未做 MySQL 8.0 实跑/EXPLAIN/锁/QPS/HA 验证。"}
    (out / "validation.json").write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    rows = "\n".join(
        f"| {c['name']} | {'PASS' if c['ok'] else 'FAIL'} | {c['detail']} |" for c in checks
    )
    md = f"""# sql_new 校验结果

**总体状态：`{status}`**（{sum(1 for c in checks if c['ok'])}/{len(checks)} 项通过）

## 1. 校验边界（务必先读）

- ✅ 已验证：基线血缘哈希、89 表排序规则覆盖、8 处类型对齐、4 处注释、
  61 条外键类型兼容、编号文件与 migrations 一致性、INSERT 行数、静态 lint、
  13 索引列存在性与 up/down 对称、SQLite 便携子集真实建表。
- ❌ **未验证**：MySQL 8.0 实际执行 89 张业务表 DDL、InnoDB 外键创建、
  `utf8mb4_unicode_ci` 运行时比较语义、EXPLAIN 执行计划、锁竞争、QPS、
  复制与高可用切换。
- 环境事实：本机无 `mysql`/`mysqld`，Docker 引擎不可用。
  **SQLite 便携子集通过 ≠ MySQL 认证**；13 的索引均为条件候选，
  没有真实执行计划，禁止声称性能收益。

## 2. 血缘：基线未被修改

`manifest.json` 记录生成时 {details['baseline_files_checked']} 个输入文件的 sha256，
本次重算全部一致 → `docs/sql/` 及各 `000001_init.*` 未被改动。

## 3. 修复计数

| 项 | 值 |
| --- | ---: |
| 业务表 | {details.get('table_count')} |
| 显式 COLLATE 表尾 | {details.get('collate_tails')}（编号文件 89 + migrations 89 镜像） |
| R2 INT→BIGINT 对齐 | {details.get('r2_aligned')}/8 |
| R3 代理主键注释 | {details.get('r3_commented')}/4 |
| 推断外键 | {details.get('fk_count')} |
| 外键类型不兼容 | {len(details.get('fk_incompatible', []))}（基线为 1） |
| migrations 镜像一致 | {details.get('migrations_checked')}/9 |
| 13 条件索引候选 | {details.get('index_candidates')} |
| SQLite 建表 | {details.get('sqlite_tables')} |

原阻塞 `fk_pin_tuan_orders_pin_tuan_id`：`pin_tuan_orders.pin_tuan_id INT
→ pin_tuan_campaigns.id BIGINT` 已由 R2 改为 BIGINT/BIGINT，`12_constraints.sql`
第 44 条不再因类型不匹配中断。

## 4. 数据行数

| 表 | 行数 |
| --- | ---: |
""" + "\n".join(f"| `{k}` | {v} |" for k, v in details.get("insert_rows", {}).items()) + f"""

## 5. 逐项结果

| 检查 | 结果 | 说明 |
| --- | --- | --- |
{rows}

## 6. 复现命令

```bash
python tools/build_sql_new.py --baseline ../../sql --out ..
python tools/validate_sql_new.py --baseline ../../sql --out ..
```

## 7. 真实 MySQL 8.0 环境待补验证

```sql
SOURCE 01_init_databases.sql;
SOURCE 02_user.sql; ... SOURCE 11_rev_evidence.sql;
SOURCE 12_constraints.sql;     -- 验证 61 条 FK 全部创建成功
SHOW CREATE TABLE `planstar_catalog`.`activities`;  -- 确认 COLLATE
EXPLAIN SELECT ... ;           -- 验证 13 的条件索引是否被优化器采用
```
"""
    (out / "VALIDATION.md").write_text(md, encoding="utf-8")
    print(json.dumps({"status": status, "checks": len(checks),
                      "passed": sum(1 for c in checks if c["ok"]),
                      "failed": [c["name"] for c in checks if not c["ok"]]}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
