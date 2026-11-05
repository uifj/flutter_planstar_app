# sql_new · 已修复版数据库脚本（可直接全新安装）

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
| R1 | 表尾显式 `COLLATE=utf8mb4_unicode_ci`，库/表/列三层统一 | 89 张表（+89 处 migrations 镜像） | F-02 |
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
