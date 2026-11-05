# Planstar 评审包校验结果

**总体状态：`PASS`**

## 1. 校验边界（务必先读）

- ✅ 已验证：评审 SQL 的静态结构、up/down 对称性、索引列存在性、索引名对称性。
- ✅ 已验证：mock 库 DDL + 全部 INSERT 在 **SQLite（开启外键）** 上真实执行，主键/唯一约束/外键由引擎强制。
- ✅ 已验证：22 项金额/状态/引用一致性用 Python `Decimal` 复算（无浮点误差）。
- ❌ **未验证**：MySQL 8.0 实际执行 89 张业务表 DDL、InnoDB 外键兼容性、utf8mb4 排序规则运行行为、EXPLAIN 执行计划、锁竞争、QPS、复制与高可用切换。
- 环境事实：本机无 `mysql`/`mysqld`，Docker CLI 存在但引擎不可用（`npipe:////./pipe/dockerDesktopLinuxEngine`）。SQLite 通过便携子集加载 mock，**不等于 MySQL 认证**。

## 2. 基线静态审计

| 指标 | 值 |
| --- | ---: |
| 数据库 | 9 |
| 业务表 + 证据表 | 89 |
| 列 | 1444 |
| 索引（含主键） | 169 |
| 推断外键 | 61（跨库 24，同库 37） |
| 类型不兼容外键 | 1 |

不兼容项：

```
planstar_marketing.pin_tuan_orders.pin_tuan_id (INT) → planstar_marketing.pin_tuan_campaigns.id (BIGINT)  [fk_pin_tuan_orders_pin_tuan_id]
```

## 3. 生成的迁移与回滚

| 文件 | 语句数 |
| --- | ---: |
| `000002_core_conventions.up.sql` | 101 |
| `000002_core_conventions.down.sql` | 101 |
| `000003_query_indexes.up.sql` | 9 |
| `000003_query_indexes.down.sql` | 9 |
| `drop_optional_fks.sql` | 61 |
| `00_schema.sql` | 34 |
| `01_seed.sql` | 25 |
| `02_validate.sql` | 27 |
| `99_teardown.sql` | 1 |

- 000002：89 条排序规则统一 + 8 处 INT→BIGINT 对齐 + 4 处元数据注释。
- 000003：8 个条件索引候选（其中 1 个为「替换」而非新增，避免左前缀冗余）。
- helpers/drop_optional_fks.sql：61 条外键反向删除。

## 4. Mock 数据

- SQLite 实际建表 **25** 张，加载 **113** 行。
- 外键检查：`PRAGMA foreign_key_check 无违规`。

| 表 | 行数 |
| --- | ---: |
| `activities` | 4 |
| `activity_events` | 5 |
| `cart_items` | 6 |
| `cities` | 3 |
| `coupons` | 5 |
| `gift_card_usages` | 1 |
| `gift_cards` | 3 |
| `group_buy_members` | 3 |
| `help` | 5 |
| `help_categories` | 3 |
| `member_reports` | 3 |
| `order_items` | 8 |
| `orders` | 8 |
| `payments` | 5 |
| `pin_tuan_campaigns` | 1 |
| `proxy_buy_orders` | 2 |
| `refunds` | 2 |
| `ticket_areas` | 4 |
| `ticket_categories` | 8 |
| `ticket_seats` | 12 |
| `user_addresses` | 4 |
| `users` | 5 |
| `venues` | 3 |
| `wallet_accounts` | 3 |
| `wallet_sequences` | 7 |

## 5. 一致性复算（对应 02_validate.sql V01–V21）

**V01–V21 全部通过，0 个失败项。**

## 6. 场景观测（预期存在，不是失败）

| 观测 | 数量 | 说明 |
| --- | ---: | --- |
| `S01 duplicate_cart_sku` | 1 | 对应 mall oms_cart_item 重复 SKU；需业务侧定义合并策略 |
| `S02 null_cart_price` | 2 | 对应 mall oms_cart_item price=NULL；下单前必须回源取价 |
| `S03 refund_scenarios` | 2 | 含全额退款 1 笔、部分退款 1 笔 |

## 7. 静态 lint

**0 error / 0 warning**（反引号、括号、语句终止、up/down 对称性、索引列存在性、索引名对称性、生成器告警）。

## 8. 复现命令

```bash
python generate_review_sql.py --sql-dir ../../ --out-dir .
python validate_review.py --review-dir . --sql-dir ../../
```

MySQL 端（有实例时）：

```sql
-- 全新空库
SOURCE 01_init_databases.sql; SOURCE 02_user.sql; ... SOURCE 11_rev_evidence.sql;
SOURCE review/000002_core_conventions.up.sql;
SOURCE review/000003_query_indexes.up.sql;
SOURCE 12_constraints.sql;          -- 可选；或按 Alibaba 规约跳过
SOURCE review/mock/00_schema.sql;
SOURCE review/mock/01_seed.sql;
SOURCE review/mock/02_validate.sql;
```
