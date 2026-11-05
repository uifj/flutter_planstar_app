# sql_new 校验结果

**总体状态：`PASS`**（12/12 项通过）

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

`manifest.json` 记录生成时 34 个输入文件的 sha256，
本次重算全部一致 → `docs/sql/` 及各 `000001_init.*` 未被改动。

## 3. 修复计数

| 项 | 值 |
| --- | ---: |
| 业务表 | 89 |
| 显式 COLLATE 表尾 | 89（编号文件 89 + migrations 89 镜像） |
| R2 INT→BIGINT 对齐 | 8/8 |
| R3 代理主键注释 | 4/4 |
| 推断外键 | 61 |
| 外键类型不兼容 | 0（基线为 1） |
| migrations 镜像一致 | 9/9 |
| 13 条件索引候选 | 8 |
| SQLite 建表 | 89 |

原阻塞 `fk_pin_tuan_orders_pin_tuan_id`：`pin_tuan_orders.pin_tuan_id INT
→ pin_tuan_campaigns.id BIGINT` 已由 R2 改为 BIGINT/BIGINT，`12_constraints.sql`
第 44 条不再因类型不匹配中断。

## 4. 数据行数

| 表 | 行数 |
| --- | ---: |
| `dict_enums` | 143 |
| `_rev_dto_field_catalog` | 1736 |
| `_rev_endpoint_catalog` | 267 |
| `_rev_dto_table_mapping` | 217 |

## 5. 逐项结果

| 检查 | 结果 | 说明 |
| --- | --- | --- |
| A1 基线 docs/sql 未被修改（34 个输入文件 sha256） | PASS | 全部一致 |
| B1 89 张表 + 表尾全部显式 COLLATE | PASS | tables=89 tails=89 missing=0 |
| B2 无残留「无 COLLATE」表尾 | PASS | legacy tails=0 |
| B3 8 处关联 ID 全部 BIGINT | PASS | 8/8 BIGINT |
| B4 4 处元数据代理主键已补 COMMENT | PASS | 4/4 |
| B5 61 条推断外键类型不兼容数归零 | PASS | fk=61 incompatible=0 missing=0 |
| B6 编号文件与 9 组 migrations up 内容一致 | PASS | 9/9 一致（其中 1 个库仅语句顺序不同: planstar_meta） |
| B7 字典/证据 INSERT 行数（143/1736/267/217） | PASS | {"dict_enums": 143, "_rev_dto_field_catalog": 1736, "_rev_endpoint_catalog": 267, "_rev_dto_table_mapping": 217} |
| C1 静态 lint（反引号/破坏性语句/提案零语句/61 条 FK 删除） | PASS | 0 issue |
| C2 13 索引列存在 + up/down 对称 | PASS | add=8 列全部存在 |
| C3 SQLite 便携子集真实建表（仅 DDL） | PASS | tables=89 |
| C4 零额外改动：从基线精确重放后逐字节一致（12 编号 + 18 migrations） | PASS | 30 个文件全部一致 |

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
