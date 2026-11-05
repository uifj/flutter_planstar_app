#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_sql_new.py
================
从评审基线 docs/sql/ 生成「已修复、可直接全新安装」的 docs/sql_new/。

设计原则（与评审报告一致）
--------------------------
1. docs/sql/ 是只读输入，本脚本绝不写入该目录；生成前后用 sha256 对比证明未改动。
2. 只落地「不改变业务语义」的确定性修复：
     R1 89 张表的表级排序规则显式化为 utf8mb4_unicode_ci
     R2 8 处关联 ID 由 INT 对齐为 BIGINT（消除 12_constraints 第 44 条的硬阻塞）
     R3 4 处元数据代理主键补 COMMENT
   并同步到 9 组 migrations 的 000001_init.up.sql，保证编号文件与迁移一致。
3. 评审包 review/000003 的 8 个条件索引是「候选」，单独放 13_query_indexes.sql
   及其 down，不混入主安装链；没有真实 EXPLAIN，不声称性能收益。
4. review/PROPOSALS.sql 的 P01-P09 会改变业务语义或拒绝历史数据，保持全注释、
   零可执行语句，放在 optional/ 下等待业务确认，不假设未声明需求。
5. 每个生成文件头部都写明与基线的差异和为什么这样设计。

用法
----
python build_sql_new.py \
    --baseline ../../sql \
    --out .. \
    --deliver "C:/Users/21263/Desktop/简历/rea-piaoniu/outputs/planstar_sql_new"
"""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
import shutil
from datetime import datetime
from pathlib import Path

NUMBERED = [
    "01_init_databases.sql",
    "02_user.sql",
    "03_catalog.sql",
    "04_ticket_inventory.sql",
    "05_order.sql",
    "06_payment.sql",
    "07_marketing.sql",
    "08_community.sql",
    "09_content_ops.sql",
    "10_dict_enums.sql",
    "11_rev_evidence.sql",
    "12_constraints.sql",
]

DB_HINT = {
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

# R2: (源文件, 表名, 列名, 原类型, 目标类型, 评审依据)
TYPE_FIXES = [
    ("03_catalog.sql", "activity_events", "ticket_group_id", "INT", "BIGINT", "F-04"),
    ("04_ticket_inventory.sql", "ticket_groups", "pin_tuan_campaign_item_id", "INT", "BIGINT", "F-04"),
    ("05_order.sql", "orders", "pin_tuan_id", "INT", "BIGINT", "F-04"),
    ("05_order.sql", "speed_packs", "pin_tuan_id", "INT", "BIGINT", "F-04"),
    ("07_marketing.sql", "coupons", "activity_event_id", "INT", "BIGINT", "F-04"),
    ("07_marketing.sql", "pin_tuan_campaigns", "shop_id", "INT", "BIGINT", "F-04"),
    ("07_marketing.sql", "pin_tuan_orders", "pin_tuan_id", "INT", "BIGINT", "F-01"),
    ("07_marketing.sql", "pin_tuan_orders", "pin_tuan_campaign_item_id", "INT", "BIGINT", "F-04"),
]

# R3: (源文件, 表名, 新增 COMMENT)
COMMENT_FIXES = [
    ("10_dict_enums.sql", "dict_enums", "字典自增代理主键（非业务 ID）"),
    ("11_rev_evidence.sql", "_rev_dto_field_catalog", "DTO 字段证据自增代理主键"),
    ("11_rev_evidence.sql", "_rev_endpoint_catalog", "端点证据自增代理主键"),
    ("11_rev_evidence.sql", "_rev_dto_table_mapping", "DTO 映射证据自增代理主键"),
]

TABLE_RE = re.compile(r"^CREATE TABLE IF NOT EXISTS `([^`]+)` \(")
TAIL_RE = re.compile(r"^\) ENGINE")
OLD_TAIL = ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT="
NEW_TAIL = ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT="

HEADER = """-- ========================================================================
--  sql_new（已修复版）· {name}
--  来源: docs/sql/{name}  |  生成: tools/build_sql_new.py
--  与基线的差异:
--    R1 表尾显式 COLLATE=utf8mb4_unicode_ci（库/表/列三层排序规则统一）
--    R2 8 处关联 ID 由 INT 对齐为 BIGINT（消除 fk_pin_tuan_orders_pin_tuan_id 阻塞）
--    R3 4 处元数据代理主键补 COMMENT
--  为什么这样设计: 以上三项不改变列语义、不拒绝历史数据、不影响 267 个 REST 契约，
--    属于可确定性执行的规范类修复；会改变业务口径的提案全部留在 optional/PROPOSALS.sql。
--  基线 docs/sql/ 未被修改；本目录可独立用于 MySQL 8.0 全新空库安装。
--  验证边界: 见 VALIDATION.md（未做真实 MySQL 8.0 执行 / EXPLAIN / 压测 / HA 验证）。
-- ========================================================================
"""

CONSTRAINT_NOTE = (
    "--  [sql_new] F-01 阻塞已由 R2 消除：子列 pin_tuan_orders.pin_tuan_id 现为 BIGINT，\n"
    "--  与父列 pin_tuan_campaigns.id BIGINT 一致，本条约束不再因类型不匹配中断。\n"
)
CONSTRAINT_NEEDLE = (
    "ALTER TABLE `planstar_marketing`.`pin_tuan_orders` "
    "ADD CONSTRAINT `fk_pin_tuan_orders_pin_tuan_id`"
)


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def write(p: Path, text: str) -> None:
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding="utf-8")


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def table_blocks(lines: list[str]) -> list[tuple[str, int, int]]:
    """返回 [(表名, 起始行, 表尾行)]，用于把修复限定在指定表内。"""
    starts = []
    for i, line in enumerate(lines):
        m = TABLE_RE.match(line)
        if m:
            starts.append((i, m.group(1)))
    blocks = []
    for start, name in starts:
        end = len(lines) - 1
        for j in range(start + 1, len(lines)):
            if TAIL_RE.match(lines[j]):
                end = j
                break
        blocks.append((name, start, end))
    return blocks


def apply_r1(lines: list[str]) -> int:
    n = 0
    for i, line in enumerate(lines):
        if OLD_TAIL in line:
            lines[i] = line.replace(OLD_TAIL, NEW_TAIL, 1)
            n += 1
    return n


def apply_type_fixes(lines: list[str], fixes, file_limited: bool, filename: str, strict: bool = True) -> dict:
    """fixes: (file, table, col, old, new, finding)。

    strict=True  编号文件模式：指定表必须存在且恰好命中 1 次。
    strict=False migrations 模式：表不在本分库文件时跳过，由调用方累计全局命中数。
    """
    blocks = table_blocks(lines)
    applied = {}
    for src, table, col, old, new, finding in fixes:
        if file_limited and src != filename:
            continue
        candidates = [(s, e) for (name, s, e) in blocks if name == table]
        if not candidates and not strict:
            continue
        if len(candidates) != 1:
            raise AssertionError(f"table block not unique: {table} in {filename} -> {len(candidates)}")
        s, e = candidates[0]
        pat = re.compile(r"^(\s*`" + re.escape(col) + r"`\s+)" + old + r"(?=\s|,)")
        hits = 0
        for i in range(s + 1, e):
            if pat.match(lines[i]):
                lines[i] = pat.sub(lambda m: m.group(1) + new, lines[i], count=1)
                hits += 1
        if hits != 1:
            raise AssertionError(f"type fix hits {hits} (expected 1): {filename}/{table}.{col}")
        applied[f"{table}.{col}"] = {"from": old, "to": new, "finding": finding}
    return applied


def apply_comment_fixes(lines: list[str], fixes, file_limited: bool, filename: str, strict: bool = True) -> dict:
    blocks = table_blocks(lines)
    applied = {}
    for src, table, comment in fixes:
        if file_limited and src != filename:
            continue
        candidates = [(s, e) for (name, s, e) in blocks if name == table]
        if not candidates and not strict:
            continue
        if len(candidates) != 1:
            raise AssertionError(f"table block not unique: {table} in {filename} -> {len(candidates)}")
        s, e = candidates[0]
        pat = re.compile(r"^(\s*`id`\s+INT NOT NULL AUTO_INCREMENT)(\s*,)")
        hits = 0
        for i in range(s + 1, e):
            m = pat.match(lines[i])
            if m:
                lines[i] = m.group(1) + " COMMENT '" + comment + "'" + m.group(2)
                hits += 1
        if hits != 1:
            raise AssertionError(f"comment fix hits {hits} (expected 1): {filename}/{table}.id")
        applied[f"{table}.id"] = comment
    return applied


def transform(text: str, filename: str | None, with_r1: bool = True) -> tuple[str, dict]:
    lines = text.splitlines()
    stats = {"r1": 0, "r2": {}, "r3": {}}
    if with_r1:
        stats["r1"] = apply_r1(lines)
    strict = filename is not None
    stats["r2"] = apply_type_fixes(lines, TYPE_FIXES, strict, filename or "", strict)
    stats["r3"] = apply_comment_fixes(lines, COMMENT_FIXES, strict, filename or "", strict)
    return "\n".join(lines) + "\n", stats


def sql_body(text: str) -> list[str]:
    """过滤注释 / USE / SET 后的有效 SQL 行，用于编号文件与 migrations 的一致性比对。"""
    out = []
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("--") or s.startswith("USE `") or s.startswith("SET "):
            continue
        out.append(s)
    return out


def copy_with_header(src: Path, dst: Path, extra: str = "") -> None:
    body = read(src)
    text = HEADER.format(name=dst.name)
    if extra:
        text += extra
    text += "\n" + body
    write(dst, text)


def build_readme(stats: dict, manifest: dict) -> str:
    return """# sql_new · 已修复版数据库脚本（可直接全新安装）

## 这是什么

`docs/sql/` 是评审基线（**本目录未对它做任何修改**）。`sql_new/` 是把评审中
「不改变业务语义」的确定性修复**实际写进 DDL** 之后的一份完整、自包含安装脚本，
不再是「先装基线再跑 ALTER 迁移」的两段式流程。

基线哈希在 `manifest.json`，`tools/validate_sql_new.py` 会重算并对比，证明基线未被动过。

## 目录结构

```
sql_new/
├── 01_init_databases.sql ... 11_rev_evidence.sql   # 修复后的建库 / 建表 / 证据数据
├── 12_constraints.sql                              # 61 条推断外键（阻塞已消除，仍可选）
├── 13_query_indexes.sql / 13_query_indexes.down.sql  # 可选：8 个条件索引候选 + 回滚
├── migrations/<9 个库>/000001_init.up.sql / .down.sql  # 与编号文件同步的镜像
├── optional/
│   ├── PROPOSALS.sql            # P01–P09 全注释、零可执行语句（需业务确认）
│   └── drop_optional_fks.sql   # 61 条外键反向删除（回滚 12 用）
├── tools/build_sql_new.py       # 本目录的可复现生成器
├── tools/validate_sql_new.py    # 校验器
├── manifest.json                # 基线 sha256 + 修复计数
├── README.md / FIXES.md / VALIDATION.md / validation.json
```

## 已执行的修复

| 编号 | 内容 | 处数 | 对应评审发现 |
| --- | --- | ---: | --- |
| R1 | 表尾显式 `COLLATE=utf8mb4_unicode_ci`，库/表/列三层统一 | {r1_numbered} 张表（+{r1_migrations} 处 migrations 镜像） | F-02 |
| R2 | 8 处关联 ID `INT` → `BIGINT` | 8 | F-01 / F-04 |
| R3 | 4 处元数据代理主键补 `COMMENT` | 4 | F-17 |

**F-01 阻塞已消除**：`planstar_marketing.pin_tuan_orders.pin_tuan_id` 现为 `BIGINT`，
与 `pin_tuan_campaigns.id BIGINT` 一致，`12_constraints.sql` 第 44 条
`fk_pin_tuan_orders_pin_tuan_id` 不再因类型不匹配中断。MySQL 要求外键两侧整数
size/sign 一致；DDL 隐式提交意味着「半途失败」会留下已生效的前 43 条约束，
因此这一步必须在首次安装前就完成。

## 执行顺序（MySQL 8.0 全新空库）

```sql
SOURCE 01_init_databases.sql;
SOURCE 02_user.sql;  SOURCE 03_catalog.sql;  SOURCE 04_ticket_inventory.sql;
SOURCE 05_order.sql; SOURCE 06_payment.sql;  SOURCE 07_marketing.sql;
SOURCE 08_community.sql; SOURCE 09_content_ops.sql;
SOURCE 10_dict_enums.sql; SOURCE 11_rev_evidence.sql;
SOURCE 12_constraints.sql;   -- 可选；按《阿里巴巴 Java 开发手册》「不得使用物理外键」可整份跳过
SOURCE 13_query_indexes.sql; -- 可选；条件索引，上线前必须 EXPLAIN / 慢查询验证
```

或者用迁移工具按库执行 `migrations/<库>/000001_init.up.sql`（内容已与编号文件同步）。

## 回滚顺序

```sql
SOURCE 13_query_indexes.down.sql;   -- 若执行过 13
SOURCE optional/drop_optional_fks.sql;  -- 若执行过 12
-- 再按库执行 migrations/<库>/000001_init.down.sql（逆序 DROP，先关外键检查）
```

**注意**：MySQL 的 `CREATE/ALTER/DROP TABLE` 会隐式提交，`ROLLBACK` 无法撤销 DDL。
`.down.sql` 是**补偿式反向 DDL**（删除表 / 索引 / 约束），不是数据恢复；
它不能还原被 DROP 表里的业务数据，也不能把「无显式 COLLATE」还原成字节级相同的 DDL。

## 未自动执行的改动（重要）

`optional/PROPOSALS.sql` 的 P01–P09 会改变业务语义、拒绝历史数据或影响 267 个
REST 契约，评审要求「对存疑点主动提问澄清，不假设未声明需求」，因此**没有**写进
01–11。需要先回答 `outputs/planstar_database_review/REPORT.md` §6 的 10 个开放问题，
典型冲突：

- `coupons.discount_rate`：DDL 注释写「万分比」，Flutter `coupon.dart` 把 `85` 当 85 折；
- `OrderStatus.PAYING = 2` 与 `OrderUtils.PAYING = 1` 不一致；
- 钱包 `amount` 有符号 vs 演示侧「正数 + expense 类型」；
- Flutter `Money` 是整数分，SQL 是 `DECIMAL(12,2)` 元；
- `activities.id` 与 `activity_id` 是两列，不能自动合并。

## 验证边界

`VALIDATION.md` 给出全部校验项。已验证：静态结构、89 表排序规则覆盖、8 处类型对齐、
4 处注释、61 条外键类型兼容、INSERT 行数、编号文件与 migrations 一致性、
SQLite 便携子集可执行性、基线哈希未变。

**未验证**：本机无 `mysql`/`mysqld`，Docker 引擎不可用，因此没有做 MySQL 8.0 实际执行、
InnoDB 外键创建、`utf8mb4_unicode_ci` 运行时比较语义、EXPLAIN、锁竞争、QPS、
复制与高可用切换。SQLite 通过便携子集 **不等于 MySQL 认证**；13 的索引均为条件候选，
没有真实执行计划，禁止声称性能收益。

## 复现

```bash
python tools/build_sql_new.py --baseline ../../sql --out ..
python tools/validate_sql_new.py --baseline ../../sql --out ..
```
""".format(
        r1_numbered=stats["r1_numbered"],
        r1_migrations=stats["r1_migrations"],
    )


def build_fixes() -> str:
    rows = [
        ("F-01", "已修复 · R2", "pin_tuan_orders.pin_tuan_id INT → BIGINT；12_constraints 第 44 条不再中断"),
        ("F-02", "已修复 · R1", "89 张表尾显式 COLLATE=utf8mb4_unicode_ci，与 9 个库声明一致"),
        ("F-03", "待业务确认 · P01/P02", "关键字段 NOT NULL / 3 个唯一约束会拒绝历史数据，未改"),
        ("F-04", "已修复 · R2", "8 处未声明外键的关联 ID 类型统一为 BIGINT"),
        ("F-05", "待业务确认", "discount_rate / 状态枚举 / 钱包符号 / Money 单位口径冲突，未改"),
        ("F-06", "待业务确认 · P03", "支付/退款/钱包幂等键与状态账本需先定契约，未改"),
        ("F-07", "待业务确认 · P08", "敏感字段加密/脱敏/最小权限需定检索需求，未改"),
        ("F-08", "待业务确认 · P04", "实体/响应封装/浏览者相对状态剥离属结构重构，未改"),
        ("F-09", "待业务确认 · P05/P06", "保留字 / 布尔 / 必备三字段 / 时间类型，未改"),
        ("F-10", "待业务确认 · P07", "两处 DOUBLE → DECIMAL，需确认精度口径，未改"),
        ("F-11", "可选 · 13", "8 个条件索引候选独立成文件，附 down；无 EXPLAIN 不声称收益"),
        ("F-12", "架构决策", "61 条推断外键仍保留在可选 12；按阿里规约可整份跳过"),
        ("F-13", "架构决策", "主键策略未改（需真实容量与 ID 生成方案）"),
        ("F-14", "仅文档", "分片/归档只给触发门槛公式，演示项目无指标，不编造三年预测"),
        ("F-15", "文档 + 回滚脚本", "down 是补偿式反向 DDL，非事务回滚；见 README"),
        ("F-16", "运行时尚未验证", "参数化 SQL / 最小权限 / 内存分页不能由静态 DDL 证明"),
        ("F-17", "已修复 · R3", "dict_enums 与 3 张证据表代理主键补 COMMENT"),
    ]
    body = "\n".join(f"| {a} | {b} | {c} |" for a, b, c in rows)
    type_rows = "\n".join(
        f"| `{src}` | `{tbl}` | `{col}` | `{old}` → `{new}` | {finding} |"
        for src, tbl, col, old, new, finding in TYPE_FIXES
    )
    comment_rows = "\n".join(
        f"| `{src}` | `{tbl}` | `{comment}` |" for src, tbl, comment in COMMENT_FIXES
    )
    return f"""# FIXES.md · sql_new 逐条修复清单

本文件是 `docs/sql/` → `docs/sql_new/` 的完整差异账。除下表列出的改动外，
01–11 的 DDL、1,736/267/217/143 条证据与字典数据**逐行保持原样**。

## R1 · 排序规则统一（F-02）

- 基线：9 个库写 `COLLATE utf8mb4_unicode_ci`，89 张表只写 `DEFAULT CHARSET=utf8mb4`。
- MySQL 8.0 行为：表未写 COLLATE 时取字符集默认 `utf8mb4_0900_ai_ci`（NO PAD），
  与库默认 `utf8mb4_unicode_ci`（PAD SPACE）不一致；438 个字符列继承表默认。
- 修复：表尾 `) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT=...`
  → `) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT=...`。
- 为什么直接写进 CREATE TABLE 而不是 `CONVERT TO`：这是全新空库安装，
  不需要重建已有表，也不产生 `ALTER TABLE` 的隐式提交与锁表窗口。

## R2 · 8 处关联 ID 类型对齐（F-01 / F-04）

| 源文件 | 表 | 列 | 变更 | 依据 |
| --- | --- | --- | --- | --- |
{type_rows}

只改类型，保留原 `COMMENT` 中的 Java 字段来源。修复后 61 条推断外键
类型不兼容数由 1 降为 0（见 `validation.json`）。

## R3 · 4 处元数据代理主键注释（F-17）

| 源文件 | 表 | 新增 COMMENT |
| --- | --- | --- |
{comment_rows}

## 12_constraints.sql 的处理

文件本体与基线一致（61 条推断外键、全库限定），只在头部补充「F-01 阻塞已消除」
的说明，并在 `fk_pin_tuan_orders_pin_tuan_id` 前加一行注释。该文件仍是**可选**的：
按《阿里巴巴 Java 开发手册》「不得使用物理外键与级联，外键概念在应用层解决」，
生产落地可整份跳过；`optional/drop_optional_fks.sql` 提供 61 条反向删除。

## 13_query_indexes.sql（可选）

来自评审包 `review/000003_query_indexes.up.sql` 的 8 个条件索引候选，
连同 `.down.sql` 一起放在根目录，但**不进入默认安装链**。每条都标注了业务场景、
证据与权衡；`feeds` 用 DROP + ADD 替换 `idx_feed_addtime`，避免左前缀冗余索引。
没有真实 QPS / EXPLAIN / 慢查询日志，不声称任何性能收益。

## optional/PROPOSALS.sql（不执行）

P01–P09 全部为注释，零可执行语句。以下是 17 条评审发现的处置状态：

| 发现 | 状态 | 说明 |
| --- | --- | --- |
{body}

## 明确没有做的事

- 没有改 `docs/sql/` 任何文件（哈希可验证）。
- 没有把「待确认」的语义变更偷偷写进 01–11。
- 没有声称 MySQL 8.0 实测、EXPLAIN、锁/QPS/HA 验证通过。
- 没有新增表、删除表或改动证据目录的 2,363 条数据行。
"""


def build_summary_html(stats: dict, validation_path: Path) -> str:
    v = {}
    if validation_path.exists():
        v = json.loads(read(validation_path))
    css = """
:root{--bg:#f7f8fa;--card:#fff;--ink:#1f2329;--sub:#5f6b7a;--line:#e3e6ec;--accent:#2f6feb;--ok:#1a7f4b;--warn:#b26a00}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:14px/1.7 -apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif}
.wrap{max-width:1080px;margin:0 auto;padding:36px 24px 64px}
h1{font-size:26px;margin:0 0 6px}h2{font-size:18px;margin:32px 0 12px;padding-bottom:8px;border-bottom:1px solid var(--line)}
.lead{color:var(--sub);margin:0 0 4px}.badge{display:inline-block;background:#e8f4ec;color:var(--ok);border:1px solid #bfe2cd;border-radius:20px;padding:2px 12px;font-size:12px;font-weight:600}
.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-top:20px}
.kpi{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:16px}
.kpi b{display:block;font-size:24px;line-height:1.2}.kpi span{color:var(--sub);font-size:12px}
.card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:18px 20px;margin-bottom:12px}
table{width:100%;border-collapse:collapse;background:var(--card);border:1px solid var(--line);border-radius:10px;overflow:hidden}
th,td{padding:9px 12px;text-align:left;border-bottom:1px solid var(--line);vertical-align:top}th{background:#f0f2f6;font-weight:600;font-size:13px}tr:last-child td{border-bottom:0}
code{background:#f0f2f6;padding:1px 5px;border-radius:4px;font-family:Consolas,Monaco,monospace;font-size:12px}
pre{background:#f0f2f6;border:1px solid var(--line);border-radius:8px;padding:14px;overflow:auto;font-size:12px;line-height:1.6}
.tag-ok{color:var(--ok);font-weight:600}.tag-wait{color:var(--warn);font-weight:600}.muted{color:var(--sub)}
ul{margin:8px 0;padding-left:22px}li{margin:4px 0}
.note{border-left:3px solid var(--accent);background:#eef4ff;padding:12px 16px;border-radius:0 8px 8px 0;margin:12px 0}
"""
    kpis = [
        ("89", "表（建库 9 个）"),
        (str(stats["r1_numbered"] + stats["r1_migrations"]), "R1 排序规则修复处"),
        ("8 + 4", "R2 类型对齐 / R3 注释"),
        ("0", "外键类型不兼容（原为 1）"),
    ]
    kpi_html = "".join(f'<div class="kpi"><b>{a}</b><span>{html.escape(b)}</span></div>' for a, b in kpis)
    status = v.get("status", "PENDING")
    checks = v.get("checks", [])
    check_rows = "".join(
        f"<tr><td>{html.escape(c.get('name',''))}</td><td class='{'tag-ok' if c.get('ok') else 'tag-wait'}'>{'PASS' if c.get('ok') else 'FAIL'}</td><td class='muted'>{html.escape(str(c.get('detail','')))}</td></tr>"
        for c in checks
    )
    return f"""<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>sql_new · 修复交付摘要</title><style>{css}</style></head><body><div class="wrap">
<h1>sql_new · 已修复版数据库脚本</h1>
<p class="lead">Planstar 票务数据库 · 基于架构评审落地的确定性修复 · MySQL 8.0 全新空库</p>
<p><span class="badge">校验 {html.escape(status)}</span> <span class="muted">生成 {datetime.now().strftime('%Y-%m-%d %H:%M')}</span></p>
<div class="grid">{kpi_html}</div>

<h2>做了什么</h2>
<div class="card">
<p><b>docs/sql/ 基线完全未改动</b>，本目录是把评审中「不改变业务语义」的修复直接写进 DDL 后的一份完整安装脚本，不再是「先装基线再跑 ALTER」的两段式流程。</p>
<ul>
<li><b>R1</b>：89 张表尾显式 <code>COLLATE=utf8mb4_unicode_ci</code>，消除库/表/列三层排序规则分叉（F-02）。同步到 9 组 migrations 镜像。</li>
<li><b>R2</b>：8 处关联 ID <code>INT → BIGINT</code>，消除 <code>fk_pin_tuan_orders_pin_tuan_id</code> 的硬阻塞（F-01/F-04）。修复后 61 条推断外键类型不兼容数归零。</li>
<li><b>R3</b>：4 处元数据代理主键补 <code>COMMENT</code>（F-17）。</li>
</ul>
</div>

<h2>没有自动做的事</h2>
<div class="card">
<p>评审要求「对存疑点主动提问澄清，不假设未声明需求」。<code>optional/PROPOSALS.sql</code> 的 P01–P09 全部保持注释、零可执行语句，因为会改变业务口径或拒绝历史数据：折扣率万分比 vs 85 折、<code>OrderStatus</code> vs <code>OrderUtils</code>、钱包金额符号、<code>Money</code> 整数分 vs <code>DECIMAL</code> 元、<code>activities.id</code> vs <code>activity_id</code> 等 10 个开放问题。</p>
<p><code>13_query_indexes.sql</code> 的 8 个索引是<b>条件候选</b>，独立可选，没有真实 EXPLAIN / QPS 数据，不声称性能收益。</p>
</div>

<h2>执行顺序</h2>
<pre>SOURCE 01_init_databases.sql;
SOURCE 02_user.sql; ... SOURCE 11_rev_evidence.sql;
SOURCE 12_constraints.sql;    -- 可选，按阿里规约可整份跳过
SOURCE 13_query_indexes.sql;  -- 可选，上线前需 EXPLAIN 验证</pre>
<p class="muted">回滚：<code>13_query_indexes.down.sql</code> → <code>optional/drop_optional_fks.sql</code> → 各库 <code>migrations/&lt;库&gt;/000001_init.down.sql</code>。MySQL DDL 隐式提交，down 是补偿式反向 DDL，不是数据恢复。</p>

<h2>校验项</h2>
<table><tr><th>检查</th><th>结果</th><th>说明</th></tr>{check_rows}</table>

<h2>验证边界</h2>
<div class="note">已验证：静态结构、排序规则覆盖、类型对齐、注释、61 条外键类型兼容、INSERT 行数、编号文件与 migrations 一致性、SQLite 便携子集可执行、基线 sha256 未变。<br>
<b>未验证</b>：本机无 mysql/mysqld、Docker 引擎不可用 → 未做 MySQL 8.0 实际执行、InnoDB 外键创建、EXPLAIN、锁竞争、QPS、复制与 HA 切换。SQLite 通过便携子集不等于 MySQL 认证。</div>

<h2>文件</h2>
<div class="card"><p><code>docs/sql_new/</code>（主目录）与 <code>outputs/planstar_sql_new/sql_new/</code>（自包含副本）。关键文档：<code>README.md</code>、<code>FIXES.md</code>、<code>VALIDATION.md</code>、<code>validation.json</code>、<code>manifest.json</code>。</p></div>
</div></body></html>
"""


def main() -> None:
    here = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", default=str(here.parent.parent / "sql"))
    parser.add_argument("--out", default=str(here.parent))
    parser.add_argument("--deliver", default="")
    parser.add_argument("--summary-only", action="store_true",
                        help="校验完成后仅刷新交付包的 index.html")
    args = parser.parse_args()

    baseline = Path(args.baseline).resolve()
    out = Path(args.out).resolve()

    if args.summary_only:
        deliver = Path(args.deliver).resolve()
        mf = json.loads(read(out / "manifest.json"))
        write(deliver / "index.html", build_summary_html(mf["fixes"], out / "validation.json"))
        print(json.dumps({"summary_refreshed": str(deliver / "index.html").replace("\\", "/")}, ensure_ascii=False))
        return
    review = baseline / "review"
    out.mkdir(parents=True, exist_ok=True)

    # 输入哈希（同时覆盖 review 的候选文件）
    inputs = [baseline / f for f in NUMBERED]
    inputs += sorted((baseline / "migrations").rglob("*.sql"))
    inputs += [review / "000003_query_indexes.up.sql", review / "000003_query_indexes.down.sql",
               review / "PROPOSALS.sql", review / "helpers" / "drop_optional_fks.sql"]
    baseline_hashes = {str(p.relative_to(baseline)).replace("\\", "/"): sha256(p) for p in inputs}

    stats = {"r1_numbered": 0, "r1_migrations": 0, "r2": {}, "r3": {}}

    # 1) 编号文件 01..12
    for name in NUMBERED:
        src = baseline / name
        text = read(src)
        if name == "01_init_databases.sql":
            # 库已显式 COLLATE，无需修复，仅补差异头
            new_text = HEADER.format(name=name) + "\n" + text
        elif name == "12_constraints.sql":
            new_text = HEADER.format(name=name) + "\n" + text
            assert CONSTRAINT_NEEDLE in new_text, "pin_tuan FK statement not found"
            new_text = new_text.replace(CONSTRAINT_NEEDLE, CONSTRAINT_NOTE + CONSTRAINT_NEEDLE, 1)
        else:
            transformed, st = transform(text, name)
            stats["r1_numbered"] += st["r1"]
            stats["r2"].update({f"{name}:{k}": v for k, v in st["r2"].items()})
            stats["r3"].update({f"{name}:{k}": v for k, v in st["r3"].items()})
            new_text = HEADER.format(name=name) + "\n" + transformed
        write(out / name, new_text)

    # 2) 13 可选索引 + down
    copy_with_header(review / "000003_query_indexes.up.sql", out / "13_query_indexes.sql",
                     extra="--  可选文件：不进入默认安装链；8 个条件索引候选，需 EXPLAIN 验证。\n")
    copy_with_header(review / "000003_query_indexes.down.sql", out / "13_query_indexes.down.sql",
                     extra="--  13_query_indexes.sql 的补偿式回滚。\n")

    # 3) migrations 镜像（up 应用同样修复，down 原样 + 差异头）
    mig_src = baseline / "migrations"
    mig_r2, mig_r3 = 0, 0
    for db_dir in sorted(p for p in mig_src.iterdir() if p.is_dir()):
        for f in sorted(db_dir.glob("*.sql")):
            rel = f.relative_to(mig_src)
            dst = out / "migrations" / rel
            if f.name.endswith(".up.sql"):
                transformed, st = transform(read(f), None)
                stats["r1_migrations"] += st["r1"]
                mig_r2 += len(st["r2"])
                mig_r3 += len(st["r3"])
                write(dst, HEADER.format(name=str(rel).replace("\\", "/")) + "\n" + transformed)
            else:
                write(dst, HEADER.format(name=str(rel).replace("\\", "/")) + "\n" + read(f))
    assert len(stats["r2"]) == 8, f"numbered R2 hits: {len(stats['r2'])}"
    assert len(stats["r3"]) == 4, f"numbered R3 hits: {len(stats['r3'])}"
    assert mig_r2 == 8, f"migrations R2 hits: {mig_r2}"
    assert mig_r3 == 4, f"migrations R3 hits: {mig_r3}"
    assert stats["r1_numbered"] == 89, f"numbered R1 hits: {stats['r1_numbered']}"
    assert stats["r1_migrations"] == 89, f"migrations R1 hits: {stats['r1_migrations']}"

    # 4) optional
    copy_with_header(review / "PROPOSALS.sql", out / "optional" / "PROPOSALS.sql",
                     extra="--  待业务确认；全注释、零可执行语句。\n")
    copy_with_header(review / "helpers" / "drop_optional_fks.sql", out / "optional" / "drop_optional_fks.sql",
                     extra="--  回滚 12_constraints.sql 的 61 条推断外键。\n")

    # 5) 文档与清单
    write(out / "README.md", build_readme(stats, {}))
    write(out / "FIXES.md", build_fixes())
    manifest = {
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "baseline_dir": str(baseline).replace("\\", "/"),
        "baseline_sha256": baseline_hashes,
        "fixes": stats,
        "policy": "docs/sql 基线不修改；仅落地不改变业务语义的 R1/R2/R3；语义变更留在 optional/PROPOSALS.sql",
    }
    write(out / "manifest.json", json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")

    # 6) 交付副本
    if args.deliver:
        deliver = Path(args.deliver).resolve()
        deliver.mkdir(parents=True, exist_ok=True)
        copy_root = deliver / "sql_new"
        if copy_root.exists():
            shutil.rmtree(copy_root)
        shutil.copytree(out, copy_root)
        for doc in ("README.md", "FIXES.md", "manifest.json"):
            shutil.copy2(out / doc, deliver / doc)
        # HTML 摘要在校验器产出 validation.json 后由 --summary 单独刷新
        write(deliver / "index.html", build_summary_html(stats, out / "validation.json"))

    print(json.dumps({
        "out": str(out).replace("\\", "/"),
        "r1_numbered": stats["r1_numbered"],
        "r1_migrations": stats["r1_migrations"],
        "r2_count": len(stats["r2"]),
        "r3_count": len(stats["r3"]),
        "baseline_inputs": len(baseline_hashes),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
