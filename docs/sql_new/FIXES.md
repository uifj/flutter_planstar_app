# FIXES.md · sql_new 逐条修复清单

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
| `03_catalog.sql` | `activity_events` | `ticket_group_id` | `INT` → `BIGINT` | F-04 |
| `04_ticket_inventory.sql` | `ticket_groups` | `pin_tuan_campaign_item_id` | `INT` → `BIGINT` | F-04 |
| `05_order.sql` | `orders` | `pin_tuan_id` | `INT` → `BIGINT` | F-04 |
| `05_order.sql` | `speed_packs` | `pin_tuan_id` | `INT` → `BIGINT` | F-04 |
| `07_marketing.sql` | `coupons` | `activity_event_id` | `INT` → `BIGINT` | F-04 |
| `07_marketing.sql` | `pin_tuan_campaigns` | `shop_id` | `INT` → `BIGINT` | F-04 |
| `07_marketing.sql` | `pin_tuan_orders` | `pin_tuan_id` | `INT` → `BIGINT` | F-01 |
| `07_marketing.sql` | `pin_tuan_orders` | `pin_tuan_campaign_item_id` | `INT` → `BIGINT` | F-04 |

只改类型，保留原 `COMMENT` 中的 Java 字段来源。修复后 61 条推断外键
类型不兼容数由 1 降为 0（见 `validation.json`）。

## R3 · 4 处元数据代理主键注释（F-17）

| 源文件 | 表 | 新增 COMMENT |
| --- | --- | --- |
| `10_dict_enums.sql` | `dict_enums` | `字典自增代理主键（非业务 ID）` |
| `11_rev_evidence.sql` | `_rev_dto_field_catalog` | `DTO 字段证据自增代理主键` |
| `11_rev_evidence.sql` | `_rev_endpoint_catalog` | `端点证据自增代理主键` |
| `11_rev_evidence.sql` | `_rev_dto_table_mapping` | `DTO 映射证据自增代理主键` |

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
| F-01 | 已修复 · R2 | pin_tuan_orders.pin_tuan_id INT → BIGINT；12_constraints 第 44 条不再中断 |
| F-02 | 已修复 · R1 | 89 张表尾显式 COLLATE=utf8mb4_unicode_ci，与 9 个库声明一致 |
| F-03 | 待业务确认 · P01/P02 | 关键字段 NOT NULL / 3 个唯一约束会拒绝历史数据，未改 |
| F-04 | 已修复 · R2 | 8 处未声明外键的关联 ID 类型统一为 BIGINT |
| F-05 | 待业务确认 | discount_rate / 状态枚举 / 钱包符号 / Money 单位口径冲突，未改 |
| F-06 | 待业务确认 · P03 | 支付/退款/钱包幂等键与状态账本需先定契约，未改 |
| F-07 | 待业务确认 · P08 | 敏感字段加密/脱敏/最小权限需定检索需求，未改 |
| F-08 | 待业务确认 · P04 | 实体/响应封装/浏览者相对状态剥离属结构重构，未改 |
| F-09 | 待业务确认 · P05/P06 | 保留字 / 布尔 / 必备三字段 / 时间类型，未改 |
| F-10 | 待业务确认 · P07 | 两处 DOUBLE → DECIMAL，需确认精度口径，未改 |
| F-11 | 可选 · 13 | 8 个条件索引候选独立成文件，附 down；无 EXPLAIN 不声称收益 |
| F-12 | 架构决策 | 61 条推断外键仍保留在可选 12；按阿里规约可整份跳过 |
| F-13 | 架构决策 | 主键策略未改（需真实容量与 ID 生成方案） |
| F-14 | 仅文档 | 分片/归档只给触发门槛公式，演示项目无指标，不编造三年预测 |
| F-15 | 文档 + 回滚脚本 | down 是补偿式反向 DDL，非事务回滚；见 README |
| F-16 | 运行时尚未验证 | 参数化 SQL / 最小权限 / 内存分页不能由静态 DDL 证明 |
| F-17 | 已修复 · R3 | dict_enums 与 3 张证据表代理主键补 COMMENT |

## 明确没有做的事

- 没有改 `docs/sql/` 任何文件（哈希可验证）。
- 没有把「待确认」的语义变更偷偷写进 01–11。
- 没有声称 MySQL 8.0 实测、EXPLAIN、锁/QPS/HA 验证通过。
- 没有新增表、删除表或改动证据目录的 2,363 条数据行。
