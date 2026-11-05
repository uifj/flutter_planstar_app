# Planstar 数据库评审包

> 目标：**Planstar 主评审 / MySQL 8.0 全新空库 / 演示项目暂无指标 / mock 适配为票务测试数据**
> 基线：`docs/sql/01..12` 与 `docs/sql/migrations/*/000001_init.*` **完全不改**。

## 1. 这个包解决什么

对 9 个服务库、89 张表、1,444 列、169 个索引、61 条推断外键做静态审计，
给出**可回滚的候选优化迁移**、**隔离的票务 mock**、**结构化评审报告**。

最重要的一条事实：`12_constraints.sql:55` 的
`fk_pin_tuan_orders_pin_tuan_id` 是 `INT → BIGINT`，在 MySQL 8.0 上**必然报错**。
按默认「遇错停止」执行会留下 43 条已提交外键、17 条未执行，属于非原子半安装。

## 2. 文件清单

| 文件 | 作用 |
| --- | --- |
| `generate_review_sql.py` | 复现生成器：解析 01..11 根 DDL，校验列/索引后产出下面的 SQL |
| `000002_core_conventions.up.sql` / `.down.sql` | 89 表排序规则统一 + 8 处 INT→BIGINT 对齐 + 4 处元数据注释；101 条语句，含完整反向回滚 |
| `000003_query_indexes.up.sql` / `.down.sql` | 8 个**条件**索引候选（7 新增 + 1 替换），每条带业务场景/证据/权衡；9 条语句成对 |
| `helpers/drop_optional_fks.sql` | 61 条推断外键的反向删除；回滚 000002 前若已建外键必须先跑它 |
| `PROPOSALS.sql` | **全部注释、不可执行**的待确认提案（NOT NULL / CHECK / 幂等 / 拆表 / 脱敏 / 分库触发条件等） |
| `mock/00_schema.sql` | 隔离库 `planstar_mock_ticketing` 的 25 张表；MySQL 8.0 与 SQLite 均可执行的便携子集 |
| `mock/01_seed.sql` | 113 行合成票务数据（无真实个人信息） |
| `mock/02_validate.sql` | MySQL 端 27 条一致性校验 + 分页对照 SQL |
| `mock/99_teardown.sql` | 整体 `DROP DATABASE` 清理（隔离库专用，安全） |
| `validate_review.py` | 静态 lint + SQLite 真实加载（外键开启）+ Python `Decimal` 金额复算 |
| `audit.json` / `validation.json` / `VALIDATION.md` | 机器可读审计结果与校验报告 |

## 3. 推荐执行顺序（MySQL 8.0 空库）

```text
01_init_databases.sql
02_user.sql … 09_content_ops.sql
10_dict_enums.sql
11_rev_evidence.sql
review/000002_core_conventions.up.sql     ← 必须在 12_constraints 之前
review/000003_query_indexes.up.sql        ← 可选，条件索引
12_constraints.sql                        ← 可选；或按 Alibaba 规约整份跳过
review/mock/00_schema.sql
review/mock/01_seed.sql
review/mock/02_validate.sql
```

**若已执行过 `12_constraints.sql`**，在跑任何 `.down.sql` 之前先执行
`review/helpers/drop_optional_fks.sql`（`MODIFY COLUMN` 不能改被外键引用的列；
`CONVERT TO CHARACTER SET` 分表执行也可能与外键冲突）。

### 回滚顺序

```text
review/000003_query_indexes.down.sql
review/helpers/drop_optional_fks.sql          （若装过外键）
review/000002_core_conventions.down.sql
-- 之后如需恢复外键：12_constraints.sql（此时 INT/BIGINT 已修复）
```

> **MySQL DDL 会隐式提交**（官方 `15.3.3`），`START TRANSACTION … ROLLBACK`
> 无法撤销 `ALTER TABLE`。这里的 `.down.sql` 是**补偿式反向 DDL**，不是事务回滚。
> 在空演示库上，最干净、字节级一致的回滚是重跑 `000001_init.down.sql` + `up.sql`。

### 已知回滚限制

- `000002` 的 `CONVERT TO CHARACTER SET` 会显式写入列级 `COLLATE`；
  down 只能恢复**有效比较行为**（`utf8mb4_0900_ai_ci`），无法恢复「未显式声明」的 DDL 形态。
- down 把 BIGINT 还原为 INT：若已写入超过 2^31 的值会失败（空库无此问题）。
- `000003` 的 `idx_feed_addtime_id` 是**替换** `idx_feed_addtime`，down 会完整还原旧索引。

## 4. 复现校验

```bash
python generate_review_sql.py --sql-dir ../../ --out-dir .
python validate_review.py --review-dir . --sql-dir ../../
```

当前结果：`PASS` — 89 表静态审计 0 error / 0 warning；mock 在 SQLite（
`PRAGMA foreign_keys=ON`）真实建 25 张表、加载 113 行、`foreign_key_check` 无违规；
Python `Decimal` 复算 V01–V21 全部通过；场景观测 3 项（重复加购 1、空价格 2、退款场景 2）。

## 5. 校验边界（不要越界解读）

- ✅ 静态结构、up/down 对称性、索引列存在性、索引名唯一性。
- ✅ mock 数据在真实 SQL 引擎（SQLite）上的主键/唯一/外键约束。
- ✅ 金额与状态一致性用 `Decimal` 精确复算。
- ❌ **未执行** MySQL 8.0 的 89 张业务表 DDL；未验证 InnoDB 外键兼容性、
  `utf8mb4_unicode_ci` 运行时比较、`EXPLAIN` 计划、锁竞争、QPS、复制/HA。
- 本机无 `mysql`/`mysqld`，Docker CLI 存在但引擎不可用
  （`npipe:////./pipe/dockerDesktopLinuxEngine`）。SQLite 通过便携子集加载 mock，
  **不等于 MySQL 认证**，更不等于性能验证。

## 6. 主动保留（不自动改）的语义决策

见 `PROPOSALS.sql` 与评审报告第 6 节。核心是：折扣率口径（万分比 vs 85 折）、
`OrderStatus` 与 `OrderUtils` 差 1、钱包流水符号、`activities.id` 与
`activity_id` 归一规则、外键策略（A/B/C）、主键策略、服务是否同实例部署、
哪些字段必须 NOT NULL。**未经确认不写任何换算或删除。**
