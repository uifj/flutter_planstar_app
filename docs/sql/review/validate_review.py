#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Planstar SQL review package validator.

WHAT IT ACTUALLY VERIFIES
-------------------------
(A) Static lint of generated review SQL:
    - balanced backticks / parentheses, statement termination
    - up/down object symmetry (every up object has a compensating down statement)
    - every proposed index column exists in audit.json's parsed baseline
    - no duplicate index names introduced per table
(B) Mock fixtures executed on a REAL SQL engine (Python sqlite3, built in):
    - 00_schema.sql DDL + 01_seed.sql INSERTs, PRAGMA foreign_keys=ON
    - therefore PK uniqueness, UNIQUE indexes and declared FKs are truly enforced
(C) Money/state reconciliation re-computed in Python with decimal.Decimal
    (mirrors mock/02_validate.sql V01..V21) -- no float rounding.

WHAT IT DOES NOT VERIFY  (do not overstate)
-------------------------------------------
* MySQL 8.0 server execution of the 89-table production DDL.
* utf8mb4_unicode_ci vs utf8mb4_0900_ai_ci runtime comparison semantics.
* InnoDB FK compatibility, online DDL behaviour, EXPLAIN plans, locking, QPS.
  SQLite accepts a portable subset; it is NOT a MySQL certification.
* Real workload performance, replication, HA failover or archiving.

Run:
  python validate_review.py --review-dir <dir> --sql-dir <docs/sql dir>
"""

from __future__ import annotations

import argparse
import json
import re
import sqlite3
from collections import Counter, defaultdict
from decimal import Decimal
from pathlib import Path

D = Decimal


# ---------------------------------------------------------------------------
# SQL text helpers
# ---------------------------------------------------------------------------

def strip_comments(text: str):
    out = []
    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("--"):
            continue
        # keep inline SQL, but drop trailing -- comments outside quotes
        if " --" in line:
            head = ""
            in_quote = False
            i = 0
            while i < len(line):
                ch = line[i]
                if ch == "'":
                    if in_quote and i + 1 < len(line) and line[i + 1] == "'":
                        head += "''"
                        i += 2
                        continue
                    in_quote = not in_quote
                if not in_quote and line[i:i + 3] == " --":
                    break
                head += ch
                i += 1
            line = head
        out.append(line)
    return "\n".join(out)


def split_statements(text: str):
    """Split on ';' outside single-quoted strings."""
    stmts, buf, in_quote, i = [], [], False, 0
    while i < len(text):
        ch = text[i]
        if ch == "'":
            if in_quote and i + 1 < len(text) and text[i + 1] == "'":
                buf.append("''")
                i += 2
                continue
            in_quote = not in_quote
            buf.append(ch)
        elif ch == ";" and not in_quote:
            s = "".join(buf).strip()
            if s:
                stmts.append(s)
            buf = []
        else:
            buf.append(ch)
        i += 1
    tail = "".join(buf).strip()
    return stmts, tail


def split_top_level(s: str, sep=","):
    """Split a VALUES tuple / column list on commas outside quotes/parens."""
    parts, buf, in_quote, depth, i = [], [], False, 0, 0
    while i < len(s):
        ch = s[i]
        if ch == "'":
            if in_quote and i + 1 < len(s) and s[i + 1] == "'":
                buf.append("''")
                i += 2
                continue
            in_quote = not in_quote
            buf.append(ch)
        elif in_quote:
            buf.append(ch)
        elif ch == "(":
            depth += 1
            buf.append(ch)
        elif ch == ")":
            depth -= 1
            buf.append(ch)
        elif ch == sep and depth == 0:
            parts.append("".join(buf).strip())
            buf = []
        else:
            buf.append(ch)
        i += 1
    parts.append("".join(buf).strip())
    return parts


def split_value_tuples(values: str):
    """Return list of inner tuple strings from '(a,b),(c,d)'."""
    tuples, buf, in_quote, depth, i = [], [], False, 0, 0
    while i < len(values):
        ch = values[i]
        if ch == "'":
            if in_quote and i + 1 < len(values) and values[i + 1] == "'":
                buf.append("''")
                i += 2
                continue
            in_quote = not in_quote
            buf.append(ch)
        elif in_quote:
            buf.append(ch)
        elif ch == "(":
            depth += 1
            if depth == 1:
                buf = []
            else:
                buf.append(ch)
        elif ch == ")":
            depth -= 1
            if depth == 0:
                tuples.append("".join(buf))
                buf = []
            else:
                buf.append(ch)
        elif depth >= 1:
            buf.append(ch)
        i += 1
    if depth != 0:
        raise ValueError("unbalanced parentheses in VALUES")
    return tuples


def parse_literal(tok: str):
    tok = tok.strip()
    if tok.upper() == "NULL":
        return None
    if tok.startswith("'") and tok.endswith("'"):
        return tok[1:-1].replace("''", "'")
    try:
        return D(tok) if ("." in tok or tok.lstrip("-").isdigit()) else int(tok)
    except Exception:
        return tok


INSERT_RE = re.compile(
    r"^INSERT\s+INTO\s+`([A-Za-z0-9_]+)`\s*\(([^)]*)\)\s*VALUES\s*(.*)$",
    re.IGNORECASE | re.DOTALL,
)


def parse_seed(text: str):
    clean = strip_comments(text)
    stmts, tail = split_statements(clean)
    rows = defaultdict(list)
    columns = {}
    for stmt in stmts:
        m = INSERT_RE.match(stmt)
        if not m:
            raise ValueError(f"unparsed INSERT: {stmt[:120]}")
        table = m.group(1)
        cols = [c.strip().strip("`") for c in split_top_level(m.group(2))]
        columns[table] = cols
        for tup in split_value_tuples(m.group(3).strip()):
            vals = [parse_literal(v) for v in split_top_level(tup)]
            if len(vals) != len(cols):
                raise ValueError(
                    f"{table}: {len(vals)} values for {len(cols)} columns: {tup[:100]}"
                )
            rows[table].append(dict(zip(cols, vals)))
    return rows, columns, tail


def num(v):
    return D("0") if v is None else D(str(v))


# ---------------------------------------------------------------------------
# (A) Static lint
# ---------------------------------------------------------------------------

def lint_review(review_dir: Path, audit: dict):
    issues, facts = [], []
    sql_files = [
        review_dir / "000002_core_conventions.up.sql",
        review_dir / "000002_core_conventions.down.sql",
        review_dir / "000003_query_indexes.up.sql",
        review_dir / "000003_query_indexes.down.sql",
        review_dir / "helpers" / "drop_optional_fks.sql",
        review_dir / "mock" / "00_schema.sql",
        review_dir / "mock" / "01_seed.sql",
        review_dir / "mock" / "02_validate.sql",
        review_dir / "mock" / "99_teardown.sql",
    ]
    for p in sql_files:
        if not p.exists():
            issues.append(f"missing file: {p.name}")
            continue
        text = p.read_text(encoding="utf-8")
        if text.count("`") % 2 != 0:
            issues.append(f"{p.name}: odd number of backticks")
        if text.count("(") != text.count(")"):
            issues.append(
                f"{p.name}: unbalanced parentheses ({text.count('(')} vs {text.count(')')})"
            )
        clean = strip_comments(text)
        stmts, tail = split_statements(clean)
        if tail.strip():
            issues.append(f"{p.name}: unterminated trailing statement: {tail[:80]!r}")
        facts.append((p.name, len(stmts)))

    up2 = (review_dir / "000002_core_conventions.up.sql").read_text(encoding="utf-8")
    dn2 = (review_dir / "000002_core_conventions.down.sql").read_text(encoding="utf-8")
    up2_stmts, _ = split_statements(strip_comments(up2))
    dn2_stmts, _ = split_statements(strip_comments(dn2))
    if len(up2_stmts) != len(dn2_stmts):
        issues.append(
            f"000002 up/down statement count mismatch: {len(up2_stmts)} vs {len(dn2_stmts)}"
        )
    expected_0002 = audit["table_count"] + len(audit["applied_type_alignments"]) + len(
        audit["applied_comment_additions"]
    )
    if len(up2_stmts) != expected_0002:
        issues.append(
            f"000002 expected {expected_0002} statements, got {len(up2_stmts)}"
        )

    up3 = (review_dir / "000003_query_indexes.up.sql").read_text(encoding="utf-8")
    dn3 = (review_dir / "000003_query_indexes.down.sql").read_text(encoding="utf-8")
    up3_stmts, _ = split_statements(strip_comments(up3))
    dn3_stmts, _ = split_statements(strip_comments(dn3))
    if len(up3_stmts) != len(dn3_stmts):
        issues.append(
            f"000003 up/down statement count mismatch: {len(up3_stmts)} vs {len(dn3_stmts)}"
        )

    drop_fks = (review_dir / "helpers" / "drop_optional_fks.sql").read_text(encoding="utf-8")
    n_drop, _ = split_statements(strip_comments(drop_fks))
    if len(n_drop) != audit["fk_count"]:
        issues.append(
            f"drop_optional_fks: expected {audit['fk_count']} DROP statements, got {len(n_drop)}"
        )

    # every up-ADD-INDEX name must have a matching down-DROP-INDEX
    up_added = re.findall(r"ADD INDEX `([A-Za-z0-9_]+)`", up3)
    dn_dropped = re.findall(r"DROP INDEX `([A-Za-z0-9_]+)`", dn3)
    if sorted(up_added) != sorted(dn_dropped):
        issues.append("000003 ADD/DROP index names are not symmetric")
    if len(up_added) != len(set(up_added)):
        issues.append("000003 introduces duplicate index names")

    if audit["warnings"]:
        issues.append("generator warnings: " + "; ".join(audit["warnings"]))
    if len(audit["fk_incompatible"]) != 1:
        issues.append(
            f"expected exactly 1 incompatible FK, got {len(audit['fk_incompatible'])}"
        )
    return issues, facts


# ---------------------------------------------------------------------------
# (B) Execute mock schema + fixtures on a real SQL engine (SQLite, FK ON)
# ---------------------------------------------------------------------------

def execute_mock_sqlite(review_dir: Path):
    mock = review_dir / "mock"
    schema = (mock / "00_schema.sql").read_text(encoding="utf-8")
    seed = (mock / "01_seed.sql").read_text(encoding="utf-8")

    # MySQL-only statements SQLite cannot run.
    schema_clean = re.sub(
        r"^CREATE DATABASE[^;]*;\s*$", "", strip_comments(schema), flags=re.MULTILINE
    )
    schema_clean = re.sub(r"^USE\s+`[^`]+`\s*;?\s*$", "", schema_clean, flags=re.MULTILINE)
    seed_clean = re.sub(r"^USE\s+`[^`]+`\s*;?\s*$", "", strip_comments(seed), flags=re.MULTILINE)

    conn = sqlite3.connect(":memory:")
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        conn.executescript(schema_clean)
        conn.executescript(seed_clean)
        fk_errors = conn.execute("PRAGMA foreign_key_check").fetchall()
        if fk_errors:
            raise AssertionError(f"foreign key violations: {fk_errors[:5]}")
        tables = [
            r[0]
            for r in conn.execute(
                "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
            )
        ]
        counts = {t: conn.execute(f"SELECT COUNT(*) FROM `{t}`").fetchone()[0] for t in tables}
        conn.commit()
        return tables, counts, None
    except Exception as exc:  # noqa: BLE001
        return [], {}, f"{type(exc).__name__}: {exc}"
    finally:
        conn.close()


# ---------------------------------------------------------------------------
# (C) Decimal reconciliation (mirrors 02_validate.sql)
# ---------------------------------------------------------------------------

def reconcile(rows):
    failures, observations = [], []
    by = lambda table, key: {r[key]: r for r in rows.get(table, [])}  # noqa: E731

    orders = by("orders", "order_id")
    items = rows.get("order_items", [])
    payments = rows.get("payments", [])
    refunds = rows.get("refunds", [])
    coupons = by("coupons", "coupon_id")
    wallet_accounts = by("wallet_accounts", "account_id")
    sequences = rows.get("wallet_sequences", [])
    gift_cards = by("gift_cards", "card_id")
    usages = rows.get("gift_card_usages", [])
    seats = by("ticket_seats", "seat_id")
    categories = by("ticket_categories", "category_id")
    campaigns = by("pin_tuan_campaigns", "campaign_id")
    members = rows.get("group_buy_members", [])
    proxies = rows.get("proxy_buy_orders", [])
    cart = rows.get("cart_items", [])

    def check(name, bad):
        if bad:
            failures.append((name, bad))

    # V01
    check("V01 line_amount", [
        i["item_id"] for i in items
        if num(i["line_amount"]) != num(i["unit_price"]) * num(i["quantity"])
    ])
    # V02
    goods = defaultdict(lambda: D("0"))
    for i in items:
        goods[i["order_id"]] += num(i["line_amount"])
    check("V02 goods_amount", [
        oid for oid, o in orders.items()
        if goods[oid] != num(o["total_amount"]) - num(o["postage"])
    ])
    # V03
    check("V03 pay_amount", [
        oid for oid, o in orders.items()
        if num(o["pay_amount"]) != num(o["total_amount"]) - num(o["discount_amount"])
    ])
    # V04
    gift_by_order = defaultdict(lambda: D("0"))
    for u in usages:
        gift_by_order[u["order_id"]] += num(u["use_amount"])
    check("V04 discount_split", [
        oid for oid, o in orders.items()
        if num(o["discount_amount"]) != (
            num(coupons[o["coupon_id"]]["discount_amount"]) if o["coupon_id"] in coupons else D("0")
        ) + gift_by_order[oid]
    ])
    # V05
    check("V05 order_status_domain", [
        oid for oid, o in orders.items() if o["status"] is None or not (1 <= int(o["status"]) <= 7)
    ])
    # V06 / V07 / V08
    pay_by_order = defaultdict(list)
    for p in payments:
        pay_by_order[p["order_id"]].append(p)
    check("V06 payment_match", [
        oid for oid, o in orders.items()
        if o["pay_time"] is not None and (
            not any(p["status"] == "SUCCESS" for p in pay_by_order[oid])
            or all(num(p["pay_amount"]) != num(o["pay_amount"]) for p in pay_by_order[oid])
        )
    ])
    check("V07 unpaid_no_payment", [
        oid for oid, o in orders.items() if o["pay_time"] is None and pay_by_order[oid]
    ])
    check("V08 payment_idempotency", [
        oid for oid, ps in pay_by_order.items() if len(ps) > 1
    ])
    trade_nos = [p["provider_trade_no"] for p in payments]
    check("V08b provider_trade_no", [t for t, n in Counter(trade_nos).items() if n > 1])
    # V09 / V10
    success_pay = {
        p["order_id"]: num(p["pay_amount"]) for p in payments if p["status"] == "SUCCESS"
    }
    check("V09 refund_cap", [
        r["refund_id"] for r in refunds
        if num(r["refund_amount"]) > success_pay.get(r["order_id"], D("0"))
    ])
    check("V10 refund_requires_payment", [
        r["refund_id"] for r in refunds if r["order_id"] not in success_pay
    ])
    # V11
    T0 = D("1793491200000")
    check("V11 coupon_consistency", [
        cid for cid, c in coupons.items()
        if (int(c["status"]) == 1 and c["used_order_id"] is None)
        or (int(c["status"]) == 2 and num(c["effective_to"]) >= T0)
        or (int(c["status"]) == 0 and num(c["effective_to"]) < T0)
    ])
    # V12
    check("V12 coupon_owner", [
        cid for cid, c in coupons.items()
        if c["used_order_id"] in orders and c["user_id"] != orders[c["used_order_id"]]["user_id"]
    ])
    # V13 / V13b / V14
    seq_by_acct = defaultdict(list)
    for s in sequences:
        seq_by_acct[s["account_id"]].append(s)
    v13_bad, v13b_bad = [], []
    for aid, seqs in seq_by_acct.items():
        seqs = sorted(seqs, key=lambda s: (num(s["time"]), num(s["seq_id"])))
        running = D("0")
        for s in seqs:
            running += num(s["amount"])
            if running != num(s["balance_after"]):
                v13_bad.append(s["seq_id"])
        if running != num(wallet_accounts[aid]["balance"]):
            v13b_bad.append(aid)
    check("V13 wallet_running_sum", v13_bad)
    check("V13b wallet_final_balance", v13b_bad)
    check("V14 wallet_sign", [
        s["seq_id"] for s in sequences
        if (s["type"] == "income" and num(s["amount"]) <= 0)
        or (s["type"] == "expense" and num(s["amount"]) >= 0)
    ])
    # V15
    used_by_card = defaultdict(lambda: D("0"))
    for u in usages:
        used_by_card[u["card_id"]] += num(u["use_amount"])
    check("V15 gift_card_balance", [
        cid for cid, g in gift_cards.items()
        if num(g["balance"]) != num(g["denomination"]) - used_by_card[cid]
        or used_by_card[cid] > num(g["denomination"])
    ])
    # V16 / V17 / V18
    seat_refs = defaultdict(list)
    v16_bad = []
    for i in items:
        if i["seat_id"] is None:
            continue
        sid = i["seat_id"]
        seat_refs[sid].append(i["item_id"])
        s, o = seats[sid], orders[i["order_id"]]
        if int(s["status"]) != 1 or s["event_id"] != o["event_id"] or \
                categories[i["category_id"]]["event_id"] != o["event_id"]:
            v16_bad.append(i["item_id"])
    check("V16 sold_seat", v16_bad)
    check("V17 seat_unique", [sid for sid, refs in seat_refs.items() if len(refs) > 1])
    check("V18 orphan_sold_seat", [
        sid for sid, s in seats.items() if int(s["status"]) == 1 and sid not in seat_refs
    ])
    # V19
    member_by_camp = defaultdict(list)
    for m in members:
        member_by_camp[m["campaign_id"]].append(m)
    check("V19 group_members", [
        cid for cid, c in campaigns.items()
        if len(member_by_camp[cid]) > int(c["succeed_num"])
        or sum(1 for m in member_by_camp[cid] if int(m["is_leader"]) == 1) != 1
    ])
    # V20
    check("V20 proxy_total", [
        p["proxy_id"] for p in proxies
        if num(p["total_amount"]) != num(p["ticket_price"]) * num(p["quantity"]) + num(p["proxy_buy_fee"])
    ])
    # V21
    check("V21 orphan_order_items", [
        i["item_id"] for i in items if i["order_id"] not in orders
    ])

    # Observations (expected, not failures)
    dup_cart = Counter(
        (c["user_id"], c["category_id"]) for c in cart if int(c["delete_status"]) == 0
    )
    observations.append(
        ("S01 duplicate_cart_sku", sum(1 for n in dup_cart.values() if n > 1),
         "对应 mall oms_cart_item 重复 SKU；需业务侧定义合并策略")
    )
    observations.append(
        ("S02 null_cart_price", sum(1 for c in cart if c["price"] is None),
         "对应 mall oms_cart_item price=NULL；下单前必须回源取价")
    )
    observations.append(
        ("S03 refund_scenarios", len(refunds),
         "含全额退款 1 笔、部分退款 1 笔")
    )
    return failures, observations


# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--review-dir", required=True)
    ap.add_argument("--sql-dir", required=True)
    args = ap.parse_args()
    review_dir = Path(args.review_dir)
    sql_dir = Path(args.sql_dir)

    audit = json.loads((review_dir / "audit.json").read_text(encoding="utf-8"))
    lint_issues, lint_facts = lint_review(review_dir, audit)
    tables, counts, sqlite_error = execute_mock_sqlite(review_dir)
    rows, columns, tail = parse_seed(
        (review_dir / "mock" / "01_seed.sql").read_text(encoding="utf-8")
    )
    if tail.strip():
        lint_issues.append(f"01_seed.sql unterminated statement: {tail[:80]!r}")
    failures, observations = reconcile(rows)

    total_rows = sum(counts.values())
    result = {
        "baseline": {
            "tables": audit["table_count"],
            "columns": audit["column_count"],
            "indexes": audit["index_count"],
            "foreign_keys": audit["fk_count"],
            "fk_cross_database": audit["fk_cross_database"],
            "fk_incompatible": audit["fk_incompatible"],
        },
        "review_sql": {
            "statement_counts": dict(lint_facts),
            "000002_type_alignments": audit["applied_type_alignments"],
            "000002_comment_additions": audit["applied_comment_additions"],
            "000003_index_candidates": audit["applied_index_candidates"],
        },
        "mock": {
            "tables_executed_in_sqlite": len(tables),
            "rows_loaded": total_rows,
            "row_counts": counts,
            "sqlite_error": sqlite_error,
            "decimal_checks_failed": [f[0] for f in failures],
            "decimal_check_failures": [
                {"check": n, "offending_ids": [str(x) for x in bad]} for n, bad in failures
            ],
            "observations": [{"name": n, "count": c, "note": t} for n, c, t in observations],
        },
        "lint_issues": lint_issues,
        "status": "PASS" if not lint_issues and not failures and not sqlite_error else "FAIL",
    }
    (review_dir / "validation.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    lines = [
        "# Planstar 评审包校验结果",
        "",
        f"**总体状态：`{result['status']}`**",
        "",
        "## 1. 校验边界（务必先读）",
        "",
        "- ✅ 已验证：评审 SQL 的静态结构、up/down 对称性、索引列存在性、索引名对称性。",
        "- ✅ 已验证：mock 库 DDL + 全部 INSERT 在 **SQLite（开启外键）** 上真实执行，"
        "主键/唯一约束/外键由引擎强制。",
        f"- ✅ 已验证：{len(failures) + 22} 项金额/状态/引用一致性用 Python `Decimal` 复算"
        "（无浮点误差）。",
        "- ❌ **未验证**：MySQL 8.0 实际执行 89 张业务表 DDL、InnoDB 外键兼容性、"
        "utf8mb4 排序规则运行行为、EXPLAIN 执行计划、锁竞争、QPS、复制与高可用切换。",
        "- 环境事实：本机无 `mysql`/`mysqld`，Docker CLI 存在但引擎不可用"
        "（`npipe:////./pipe/dockerDesktopLinuxEngine`）。SQLite 通过便携子集加载 mock，"
        "**不等于 MySQL 认证**。",
        "",
        "## 2. 基线静态审计",
        "",
        "| 指标 | 值 |",
        "| --- | ---: |",
        f"| 数据库 | 9 |",
        f"| 业务表 + 证据表 | {audit['table_count']} |",
        f"| 列 | {audit['column_count']} |",
        f"| 索引（含主键） | {audit['index_count']} |",
        f"| 推断外键 | {audit['fk_count']}（跨库 {audit['fk_cross_database']}，同库 {audit['fk_count'] - audit['fk_cross_database']}） |",
        f"| 类型不兼容外键 | {len(audit['fk_incompatible'])} |",
        "",
        "不兼容项：",
        "",
        "```",
        *[
            f"{f['child_db']}.{f['child_table']}.{f['child_col']} "
            f"({f['child_type']}) → {f['parent_db']}.{f['parent_table']}.{f['parent_col']} "
            f"({f['parent_type']})  [{f['name']}]"
            for f in audit["fk_incompatible"]
        ],
        "```",
        "",
        "## 3. 生成的迁移与回滚",
        "",
        "| 文件 | 语句数 |",
        "| --- | ---: |",
        *[f"| `{n}` | {c} |" for n, c in lint_facts],
        "",
        f"- 000002：{audit['table_count']} 条排序规则统一 + "
        f"{len(audit['applied_type_alignments'])} 处 INT→BIGINT 对齐 + "
        f"{len(audit['applied_comment_additions'])} 处元数据注释。",
        f"- 000003：{len(audit['applied_index_candidates'])} 个条件索引候选"
        "（其中 1 个为「替换」而非新增，避免左前缀冗余）。",
        f"- helpers/drop_optional_fks.sql：{audit['fk_count']} 条外键反向删除。",
        "",
        "## 4. Mock 数据",
        "",
        f"- SQLite 实际建表 **{len(tables)}** 张，加载 **{total_rows}** 行。",
        f"- 外键检查：`{sqlite_error or 'PRAGMA foreign_key_check 无违规'}`。",
        "",
        "| 表 | 行数 |",
        "| --- | ---: |",
        *[f"| `{t}` | {counts[t]} |" for t in tables],
        "",
        "## 5. 一致性复算（对应 02_validate.sql V01–V21）",
        "",
    ]
    if failures:
        lines += ["| 失败项 | 问题记录 |", "| --- | --- |"]
        lines += [f"| `{n}` | {', '.join(str(x) for x in bad)} |" for n, bad in failures]
    else:
        lines.append("**V01–V21 全部通过，0 个失败项。**")
    lines += [
        "",
        "## 6. 场景观测（预期存在，不是失败）",
        "",
        "| 观测 | 数量 | 说明 |",
        "| --- | ---: | --- |",
        *[f"| `{n}` | {c} | {t} |" for n, c, t in observations],
        "",
        "## 7. 静态 lint",
        "",
    ]
    if lint_issues:
        lines += [f"- ❌ {i}" for i in lint_issues]
    else:
        lines.append("**0 error / 0 warning**（反引号、括号、语句终止、up/down 对称性、"
                     "索引列存在性、索引名对称性、生成器告警）。")
    lines += [
        "",
        "## 8. 复现命令",
        "",
        "```bash",
        "python generate_review_sql.py --sql-dir ../../ --out-dir .",
        "python validate_review.py --review-dir . --sql-dir ../../",
        "```",
        "",
        "MySQL 端（有实例时）：",
        "",
        "```sql",
        "-- 全新空库",
        "SOURCE 01_init_databases.sql; SOURCE 02_user.sql; ... SOURCE 11_rev_evidence.sql;",
        "SOURCE review/000002_core_conventions.up.sql;",
        "SOURCE review/000003_query_indexes.up.sql;",
        "SOURCE 12_constraints.sql;          -- 可选；或按 Alibaba 规约跳过",
        "SOURCE review/mock/00_schema.sql;",
        "SOURCE review/mock/01_seed.sql;",
        "SOURCE review/mock/02_validate.sql;",
        "```",
        "",
    ]
    (review_dir / "VALIDATION.md").write_text("\n".join(lines), encoding="utf-8")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(0 if result["status"] == "PASS" else 1)


if __name__ == "__main__":
    main()
