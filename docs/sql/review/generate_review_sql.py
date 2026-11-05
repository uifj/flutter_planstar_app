#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Planstar SQL review package generator.

WHY THIS EXISTS
---------------
The 000001 baseline migrations were generated once from a monolithic
reversed-schema.sql and are NOT reproducible (their input file is now only
a 64-line index).  This generator deliberately reads the *numbered root
DDL files* (01..11) instead, so every candidate change below is checked
against the real column names, real column types and real index names.

It does NOT edit any 000001 baseline file.  It emits:
  000002_core_conventions.up.sql / .down.sql
  000003_query_indexes.up.sql    / .down.sql
  helpers/drop_optional_fks.sql  (reverse of 12_constraints.sql)
  audit.json                     (machine-readable inventory)

Run:
  python generate_review_sql.py --sql-dir <path to docs/sql> --out-dir <review dir>

DESIGN BOUNDARY
---------------
* Fresh MySQL 8.0 demo environment only.
* No unconfirmed business semantics are changed: money/status/nullability
  decisions stay in PROPOSALS (report), not in executable DDL.
* All DDL is compensating/rollback-able; MySQL DDL implicitly commits,
  so a down script is explicit inverse DDL, never COMMIT/ROLLBACK.
"""

from __future__ import annotations

import argparse
import json
import re
from collections import OrderedDict
from pathlib import Path

# ---------------------------------------------------------------------------
# 1. Parse the baseline DDL
# ---------------------------------------------------------------------------

FILE_DB_HINT = {
    "02_user.sql": "planstar_user",
    "03_catalog.sql": "planstar_catalog",
    "04_ticket_inventory.sql": "planstar_ticket",
    "05_order.sql": "planstar_order",
    "06_payment.sql": "planstar_payment",
    "07_marketing.sql": "planstar_marketing",
    "08_community.sql": "planstar_community",
    "09_content_ops.sql": "planstar_content",
    "10_dict_enums.sql": "planstar_meta",
    "11_rev_evidence.sql": "planstar_meta",
}

COLUMN_RE = re.compile(r"^\s+`([A-Za-z0-9_]+)`\s+([A-Za-z]+(?:\([^)]*\))?)")
INDEX_RE = re.compile(
    r"^\s+(PRIMARY KEY|UNIQUE KEY|KEY)\s+"
    r"(?:`([A-Za-z0-9_]+)`\s*)?\(([^)]*)\)"
)
CREATE_RE = re.compile(r"^CREATE TABLE IF NOT EXISTS\s+`([A-Za-z0-9_]+)`\s*\(")
USE_RE = re.compile(r"^USE\s+`([A-Za-z0-9_]+)`\s*;")


def parse_baseline(sql_dir: Path):
    tables = OrderedDict()  # (db, name) -> dict
    for filename, hint_db in FILE_DB_HINT.items():
        path = sql_dir / filename
        if not path.exists():
            raise SystemExit(f"missing baseline file: {path}")
        current_db = hint_db
        lines = path.read_text(encoding="utf-8").splitlines()
        i = 0
        while i < len(lines):
            line = lines[i]
            m = USE_RE.match(line)
            if m:
                current_db = m.group(1)
                i += 1
                continue
            m = CREATE_RE.match(line)
            if not m:
                i += 1
                continue
            tname = m.group(1)
            columns = OrderedDict()
            indexes = OrderedDict()
            i += 1
            while i < len(lines):
                inner = lines[i]
                if re.match(r"^\)\s+ENGINE=", inner):
                    break
                cm = COLUMN_RE.match(inner)
                if cm:
                    col, typ = cm.group(1), cm.group(2)
                    columns[col] = {
                        "type": typ,
                        "definition": inner.strip().rstrip(",").strip(),
                        "has_comment": "COMMENT " in inner,
                    }
                    i += 1
                    continue
                im = INDEX_RE.match(inner)
                if im:
                    kind, idx_name, cols = im.group(1), im.group(2), im.group(3)
                    key = idx_name or "PRIMARY"
                    indexes[key] = {
                        "kind": kind,
                        "columns": [c.strip().strip("`") for c in cols.split(",")],
                    }
                i += 1
            tables[(current_db, tname)] = {
                "columns": columns,
                "indexes": indexes,
                "source": filename,
            }
            i += 1
    return tables


def parse_constraints(sql_dir: Path):
    path = sql_dir / "12_constraints.sql"
    fks = []
    for line in path.read_text(encoding="utf-8").splitlines():
        m = re.match(
            r"^ALTER TABLE\s+`([A-Za-z0-9_]+)`\.`([A-Za-z0-9_]+)`\s+"
            r"ADD CONSTRAINT\s+`([A-Za-z0-9_]+)`\s+"
            r"FOREIGN KEY\s+\(`([A-Za-z0-9_]+)`\)\s+"
            r"REFERENCES\s+`([A-Za-z0-9_]+)`\.`([A-Za-z0-9_]+)`\s+"
            r"\(`([A-Za-z0-9_]+)`\)\s*;",
            line,
        )
        if m:
            fks.append(
                {
                    "child_db": m.group(1),
                    "child_table": m.group(2),
                    "name": m.group(3),
                    "child_col": m.group(4),
                    "parent_db": m.group(5),
                    "parent_table": m.group(6),
                    "parent_col": m.group(7),
                }
            )
    return fks


# ---------------------------------------------------------------------------
# 2. Candidate changes (validated against the parse above)
# ---------------------------------------------------------------------------

# INT -> BIGINT alignment.  Only columns whose *referenced canonical* ID is
# BIGINT.  No monetary/status semantics involved.
TYPE_ALIGNMENTS = [
    ("planstar_marketing", "pin_tuan_orders", "pin_tuan_id",
     "planstar_marketing.pin_tuan_campaigns.id"),
    ("planstar_marketing", "pin_tuan_orders", "pin_tuan_campaign_item_id",
     "planstar_marketing.pin_tuan_campaign_items.id"),
    ("planstar_order", "orders", "pin_tuan_id",
     "planstar_marketing.pin_tuan_campaigns.id"),
    ("planstar_order", "speed_packs", "pin_tuan_id",
     "planstar_marketing.pin_tuan_campaigns.id"),
    ("planstar_catalog", "activity_events", "ticket_group_id",
     "planstar_ticket.ticket_groups.id"),
    ("planstar_ticket", "ticket_groups", "pin_tuan_campaign_item_id",
     "planstar_marketing.pin_tuan_campaign_items.id"),
    ("planstar_marketing", "coupons", "activity_event_id",
     "planstar_catalog.activity_events.id"),
    ("planstar_marketing", "pin_tuan_campaigns", "shop_id",
     "planstar_catalog.shops.shop_id"),
]

# Columns that lack COMMENT in the baseline (metadata surrogate PKs only).
COMMENT_ADDITIONS = [
    ("planstar_meta", "dict_enums", "id", "字典自增代理主键（非业务 ID）"),
    ("planstar_meta", "_rev_dto_field_catalog", "id", "DTO 字段证据自增代理主键"),
    ("planstar_meta", "_rev_endpoint_catalog", "id", "端点证据自增代理主键"),
    ("planstar_meta", "_rev_dto_table_mapping", "id", "DTO 映射证据自增代理主键"),
]

# Conditional query indexes.  Each one is tied to a concrete Flutter scenario
# found in the read-only audit.  They are CANDIDATES, not measured wins.
INDEX_CANDIDATES = [
    {
        "db": "planstar_order", "table": "orders",
        "name": "idx_order_user_addtime",
        "cols": ["user_id", "add_time", "order_id"],
        "scenario": "我的订单列表：按 user_id 过滤、按 add_time 倒序、以 order_id 做游标翻页",
        "evidence": "lib/features/order/application/order_list_controller.dart → repository.findAll() 后在本地按 submittedAt/placedAt 排序",
        "note": "与现有 idx_order_user(user_id,status) 部分重叠；保留两者仅在「状态筛选」与「全量时间线」两种查询都真实存在时才合理",
    },
    {
        "db": "planstar_order", "table": "order_events",
        "name": "idx_orderev_order_time",
        "cols": ["order_id", "add_time", "id"],
        "scenario": "订单详情状态时间线：按 order_id 取事件并按发生时间排序",
        "evidence": "order_events.order_id + add_time（05_order.sql:86,92）；现有 idx_orderev_order 仅覆盖 order_id",
        "note": "覆盖索引候选；若时间线永远按主键顺序读取则可不建",
    },
    {
        "db": "planstar_catalog", "table": "activity_events",
        "name": "idx_event_act_start",
        "cols": ["activity_id", "start", "id"],
        "scenario": "选票页场次日历：按演出取场次并按开演时间升序",
        "evidence": "lib/features/catalog/ui/show_list_page.dart → firstSessionAt 升序排序",
        "note": "与现有 idx_event_act、idx_event_start 各重叠一部分；Alibaba 索引规约要求避免冗余，上线前用 EXPLAIN 二选一",
    },
    {
        "db": "planstar_ticket", "table": "ticket_categories",
        "name": "idx_tc_event_status",
        "cols": ["activity_event_id", "status", "id"],
        "scenario": "选票页票档列表：按场次 + 在售状态取票档",
        "evidence": "04_ticket_inventory.sql:22,39；现有 idx_tc_event 仅覆盖场次",
        "note": "status 语义与取值尚未确认，条件索引；若 status 区分度极低则收益有限",
    },
    {
        "db": "planstar_marketing", "table": "coupons",
        "name": "idx_coupon_user_status_expiry",
        "cols": ["user_id", "status", "effective_time_to", "id"],
        "scenario": "我的优惠券：可用券按到期时间升序（临期排序）",
        "evidence": "lib/features/marketing/coupon_page.dart / coupon.dart → daysUntilExpiry、isExpiringSoon 目前为客户端本地排序",
        "note": "当前 Flutter 为本地过滤排序，服务端尚无该查询契约；属预备候选，不应据此声称性能收益",
    },
    {
        "db": "planstar_payment", "table": "wallet_sequences",
        "name": "idx_walletseq_account_time",
        "cols": ["account_id", "time", "id"],
        "scenario": "钱包账户流水：按 account_id 分页并按时间倒序",
        "evidence": "06_payment.sql:107,112；现有 idx_walletseq_user(user_id,time) 走用户维度",
        "note": "与现有索引口径不同（account_id vs user_id）；只有当服务端确实按账户查询时才需要",
    },
    {
        "db": "planstar_community", "table": "reviews",
        "name": "idx_review_act_time",
        "cols": ["activity_id", "add_time", "id"],
        "scenario": "演出详情评价列表：按演出取评价并按时间倒序 + 游标翻页",
        "evidence": "08_community.sql:22-36（reviews 同时含 page_index/page_size/total_num/data 分页封装字段）",
        "note": "先要把分页封装字段从实体表中剥离，否则查询口径仍不明确",
    },
    {
        "db": "planstar_community", "table": "feeds",
        "name": "idx_feed_addtime_id",
        "cols": ["add_time", "id"],
        # 生成器检查时发现基线已有 idx_feed_addtime(add_time)：直接新增会造成
        # 左前缀冗余（Alibaba 索引规约明确反对）。因此改为「替换」，down 可完整还原。
        "replace": "idx_feed_addtime",
        "scenario": "发现流游标分页：以 (add_time,id) 作为稳定游标，替代 OFFSET 深分页",
        "evidence": "lib/features/discover/data/planstar_feed_api.dart → 客户端丢弃 next_page_key/has_more；基线已有 idx_feed_addtime(add_time)",
        "note": "替换而非新增；feeds 表目前把 next_page_key/has_more 当实体字段持久化，索引只解决排序，不解决建模问题",
    },
]


# ---------------------------------------------------------------------------
# 3. Emit
# ---------------------------------------------------------------------------

BANNER = """-- =======================================================================
--  Planstar 数据库评审 · 候选优化迁移
--  目标：MySQL 8.0 / InnoDB / utf8mb4 / 全新空库演示环境
--  生成：generate_review_sql.py（读取 01..11 根 DDL，不修改 000001 基线）
--  方言：MySQL 8.0。所有 DDL 均隐式提交，回滚依赖本包的 .down.sql 补偿脚本。
--  重要：本文件不是「已验证的性能优化」，索引项均为条件候选，
--        上线前必须用真实 EXPLAIN / 慢查询日志验证。
-- =======================================================================
"""


def emit_000002(tables, out_dir: Path):
    warnings = []
    up = [BANNER]
    down = [BANNER]
    up.append("-- -----------------------------------------------------------------------")
    up.append("-- A. 统一排序规则：表级 utf8mb4（无 COLLATE）→ 显式 utf8mb4_unicode_ci")
    up.append("--    事实：9 个库显式 COLLATE utf8mb4_unicode_ci；89 张表只写 CHARSET=utf8mb4，")
    up.append("--    MySQL 8.0 会取字符集默认 utf8mb4_0900_ai_ci（NO PAD），与库默认（PAD SPACE）不一致。")
    up.append("--    438 个字符列继承表默认。CONVERT TO 会重建表并显式设置列排序规则。")
    up.append("--    执行顺序：必须在 12_constraints.sql 之前；若已建外键，先跑 helpers/drop_optional_fks.sql。")
    up.append("-- -----------------------------------------------------------------------\n")
    down.append("-- A'. 回滚排序规则：恢复为 MySQL 8.0 的 utf8mb4 默认排序规则。")
    down.append("--     注意：CONVERT TO 会显式写入列级 COLLATE，无法自动还原成「无显式声明」；")
    down.append("--     若要求 DDL 字节级一致，请在空库上重跑 000001 down/up（见 README）。\n")

    for (db, tname) in tables:
        up.append(
            f"ALTER TABLE `{db}`.`{tname}` CONVERT TO CHARACTER SET utf8mb4 "
            f"COLLATE utf8mb4_unicode_ci;"
        )
        down.append(
            f"ALTER TABLE `{db}`.`{tname}` CONVERT TO CHARACTER SET utf8mb4 "
            f"COLLATE utf8mb4_0900_ai_ci;"
        )
    up.append("")
    down.append("")

    up.append("-- -----------------------------------------------------------------------")
    up.append("-- B. 关联字段类型对齐 INT → BIGINT（Alibaba：关联字段数据类型必须绝对一致）")
    up.append("--    P0：pin_tuan_orders.pin_tuan_id 是 12_constraints.sql 第 55 行的 FK")
    up.append("--    「INT → BIGINT」不兼容，会让全新安装在此处报错并留下 43/61 条半安装外键。")
    up.append("--    其余 7 处虽未声明 FK，但与 BIGINT 主键语义关联，一并对齐。")
    up.append("--    不处理 actor_qr_codes.actor_id VARCHAR(64)：可能存非数字 QR token，需业务确认。")
    up.append("-- -----------------------------------------------------------------------\n")
    down.append("-- B'. 回滚类型：恢复原 INT 定义（列注释保留）。\n")

    applied_alignments = []
    for db, tname, col, canonical in TYPE_ALIGNMENTS:
        key = (db, tname)
        if key not in tables:
            warnings.append(f"type alignment skipped, table missing: {db}.{tname}")
            continue
        colinfo = tables[key]["columns"].get(col)
        if not colinfo:
            warnings.append(f"type alignment skipped, column missing: {db}.{tname}.{col}")
            continue
        if colinfo["type"].split("(")[0].upper() != "INT":
            warnings.append(
                f"type alignment skipped, expected INT got {colinfo['type']}: {db}.{tname}.{col}"
            )
            continue
        new_def = re.sub(r"\bINT\b", "BIGINT", colinfo["definition"], count=1)
        up.append(
            f"-- {db}.{tname}.{col}  ← {canonical}\n"
            f"ALTER TABLE `{db}`.`{tname}` MODIFY COLUMN {new_def};"
        )
        down.append(
            f"ALTER TABLE `{db}`.`{tname}` MODIFY COLUMN {colinfo['definition']};"
        )
        applied_alignments.append(f"{db}.{tname}.{col}")
    up.append("")
    down.append("")

    up.append("-- -----------------------------------------------------------------------")
    up.append("-- C. 补齐 4 个元数据代理主键的列注释（ISO/IEC 11179 数据元可解释性 / Alibaba 注释规约）")
    up.append("-- -----------------------------------------------------------------------\n")
    down.append("-- C'. 回滚：去掉这 4 列的注释（恢复基线「无注释」状态）。\n")
    applied_comments = []
    for db, tname, col, text in COMMENT_ADDITIONS:
        info = tables[(db, tname)]["columns"].get(col)
        if not info or info["has_comment"]:
            warnings.append(f"comment skipped: {db}.{tname}.{col}")
            continue
        up.append(
            f"ALTER TABLE `{db}`.`{tname}` MODIFY COLUMN {info['definition']} "
            f"COMMENT '{text}';"
        )
        down.append(
            f"ALTER TABLE `{db}`.`{tname}` MODIFY COLUMN {info['definition']};"
        )
        applied_comments.append(f"{db}.{tname}.{col}")
    up.append("\n-- EOF")
    down.append("\n-- EOF")

    (out_dir / "000002_core_conventions.up.sql").write_text("\n".join(up) + "\n", encoding="utf-8")
    (out_dir / "000002_core_conventions.down.sql").write_text("\n".join(down) + "\n", encoding="utf-8")
    return applied_alignments, applied_comments, warnings


def emit_000003(tables, out_dir: Path):
    warnings = []
    up = [BANNER]
    down = [BANNER]
    up.append("-- -----------------------------------------------------------------------")
    up.append("-- 条件查询索引候选（全部为普通二级索引，可在空库安全回滚）")
    up.append("-- 每条都标注业务场景与证据；没有真实 QPS/执行计划，禁止声称性能收益。")
    up.append("-- 执行顺序：000002 之后、12_constraints.sql 之前或之后均可（索引名不与外键自动索引冲突）。")
    up.append("-- -----------------------------------------------------------------------\n")
    down.append("-- 回滚：删除本迁移新增的索引。若某个索引被外键依赖，先删外键。\n")

    applied = []
    for c in INDEX_CANDIDATES:
        key = (c["db"], c["table"])
        if key not in tables:
            warnings.append(f"index skipped, table missing: {c['db']}.{c['table']}")
            continue
        tinfo = tables[key]
        missing = [col for col in c["cols"] if col not in tinfo["columns"]]
        if missing:
            warnings.append(
                f"index skipped, missing columns {missing}: {c['db']}.{c['table']}.{c['name']}"
            )
            continue
        if c["name"] in tinfo["indexes"]:
            warnings.append(f"index skipped, name collision: {c['db']}.{c['table']}.{c['name']}")
            continue
        replace = c.get("replace")
        if replace and replace not in tinfo["indexes"]:
            warnings.append(f"index skipped, replace target missing: {c['db']}.{c['table']}.{replace}")
            continue
        cols = ",".join(f"`{col}`" for col in c["cols"])
        head = (
            f"-- [{c['db']}.{c['table']}] {c['name']}"
            + (f"  （替换 {replace}）" if replace else "")
            + f"\n"
            f"--   场景：{c['scenario']}\n"
            f"--   证据：{c['evidence']}\n"
            f"--   权衡：{c['note']}\n"
        )
        if replace:
            old = tinfo["indexes"][replace]
            old_cols = ",".join(f"`{col}`" for col in old["columns"])
            up.append(
                head
                + f"ALTER TABLE `{c['db']}`.`{c['table']}` DROP INDEX `{replace}`;\n"
                + f"ALTER TABLE `{c['db']}`.`{c['table']}` ADD INDEX `{c['name']}` ({cols});\n"
            )
            down.append(
                f"ALTER TABLE `{c['db']}`.`{c['table']}` DROP INDEX `{c['name']}`;\n"
                f"ALTER TABLE `{c['db']}`.`{c['table']}` ADD "
                f"{'UNIQUE ' if old['kind'] == 'UNIQUE KEY' else ''}INDEX `{replace}` ({old_cols});"
            )
        else:
            up.append(
                head + f"ALTER TABLE `{c['db']}`.`{c['table']}` ADD INDEX `{c['name']}` ({cols});\n"
            )
            down.append(
                f"ALTER TABLE `{c['db']}`.`{c['table']}` DROP INDEX `{c['name']}`;"
            )
        applied.append(f"{c['db']}.{c['table']}.{c['name']}")
    up.append("-- EOF")
    down.append("\n-- EOF")
    (out_dir / "000003_query_indexes.up.sql").write_text("\n".join(up) + "\n", encoding="utf-8")
    (out_dir / "000003_query_indexes.down.sql").write_text("\n".join(down) + "\n", encoding="utf-8")
    return applied, warnings


def emit_drop_fks(fks, out_dir: Path):
    helpers = out_dir / "helpers"
    helpers.mkdir(parents=True, exist_ok=True)
    lines = [
        BANNER,
        "-- helpers/drop_optional_fks.sql",
        "-- 用途：回滚 000002 之前先移除 12_constraints.sql 安装的推断外键。",
        "-- 原因：ALTER TABLE MODIFY COLUMN 不能改被外键引用的列类型；",
        "--       CONVERT TO CHARACTER SET 在父子表分别执行时也可能与外键冲突。",
        "-- 说明：12_constraints.sql 的 61 条外键全部是【按字段名推断】，不是真实库导出；",
        "--       删除它们不丢失业务数据，只移除数据库级引用完整性检查。",
        "-- 重建：重新执行 ../../12_constraints.sql（需先跑 000002 修复 INT/BIGINT）。",
        "-- -----------------------------------------------------------------------\n",
    ]
    for fk in fks:
        lines.append(
            f"ALTER TABLE `{fk['child_db']}`.`{fk['child_table']}` "
            f"DROP FOREIGN KEY `{fk['name']}`;"
        )
    lines.append("\n-- EOF")
    (helpers / "drop_optional_fks.sql").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return len(fks)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sql-dir", required=True)
    ap.add_argument("--out-dir", required=True)
    args = ap.parse_args()
    sql_dir = Path(args.sql_dir)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    tables = parse_baseline(sql_dir)
    fks = parse_constraints(sql_dir)
    alignments, comments, w1 = emit_000002(tables, out_dir)
    indexes, w2 = emit_000003(tables, out_dir)
    n_fks = emit_drop_fks(fks, out_dir)

    # FK type audit: compare actual declared types.
    fk_audit = []
    for fk in fks:
        child = tables.get((fk["child_db"], fk["child_table"]), {}).get("columns", {}).get(fk["child_col"])
        parent = tables.get((fk["parent_db"], fk["parent_table"]), {}).get("columns", {}).get(fk["parent_col"])
        fk_audit.append(
            {
                **fk,
                "child_type": child["type"] if child else None,
                "parent_type": parent["type"] if parent else None,
                "compatible": bool(child and parent and child["type"] == parent["type"]),
            }
        )

    audit = {
        "table_count": len(tables),
        "column_count": sum(len(t["columns"]) for t in tables.values()),
        "index_count": sum(len(t["indexes"]) for t in tables.values()),
        "fk_count": len(fks),
        "fk_incompatible": [f for f in fk_audit if not f["compatible"]],
        "fk_cross_database": sum(1 for f in fks if f["child_db"] != f["parent_db"]),
        "tables_by_db": {
            db: sum(1 for (d, _) in tables if d == db)
            for db in sorted({d for (d, _) in tables})
        },
        "applied_type_alignments": alignments,
        "applied_comment_additions": comments,
        "applied_index_candidates": indexes,
        "warnings": w1 + w2,
    }
    (out_dir / "audit.json").write_text(
        json.dumps(audit, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(audit, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
