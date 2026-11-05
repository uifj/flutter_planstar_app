-- ========================================================================
--  sql_rebuildnew · 13_query_indexes.down.sql
--  来源  : docs/sql_new（已含 R1 显式 COLLATE / R2 8 处 BIGINT 对齐 / R3 4 处注释）
--  用途  : 在真实 MySQL（Docker 镜像 8dbcf531a03a，mysql:8 / 8.4.10 LTS）上完整实跑验证。
--  与 sql_new 的差异:
--     (a) 替换 sql_new 中「未做真实 MySQL 执行」的过时生成头部；
--     (b) R4 确定性规范修复：TINYINT(1) -> TINYINT，消除 MySQL 8.4 的 1681
--         「整数显示宽度已弃用」告警。显示宽度不影响存储、值域、可空性、默认值，
--         本库经 JSON REST 访问、无 JDBC tinyInt1isBit 依赖，故语义等价。
--  原样版本（未做 R4，119 条 1681 告警）见 00_all_faithful.sql。
--  未执行 deep_review 的 P01–P17 语义提案（Q1–Q10 未确认）。
--  实跑结果: 见 VALIDATION.md / validation.json / run_log_clean.txt
-- ========================================================================

--  13_query_indexes.sql 的补偿式回滚。

-- =======================================================================
--  Planstar 数据库评审 · 候选优化迁移
--  目标：MySQL 8.0 / InnoDB / utf8mb4 / 全新空库演示环境
--  生成：generate_review_sql.py（读取 01..11 根 DDL，不修改 000001 基线）
--  方言：MySQL 8.0。所有 DDL 均隐式提交，回滚依赖本包的 .down.sql 补偿脚本。
--  重要：本文件不是「已验证的性能优化」，索引项均为条件候选，
--        上线前必须用真实 EXPLAIN / 慢查询日志验证。
-- =======================================================================

-- 回滚：删除本迁移新增的索引。若某个索引被外键依赖，先删外键。

ALTER TABLE `planstar_order`.`orders` DROP INDEX `idx_order_user_addtime`;
ALTER TABLE `planstar_order`.`order_events` DROP INDEX `idx_orderev_order_time`;
ALTER TABLE `planstar_catalog`.`activity_events` DROP INDEX `idx_event_act_start`;
ALTER TABLE `planstar_ticket`.`ticket_categories` DROP INDEX `idx_tc_event_status`;
ALTER TABLE `planstar_marketing`.`coupons` DROP INDEX `idx_coupon_user_status_expiry`;
ALTER TABLE `planstar_payment`.`wallet_sequences` DROP INDEX `idx_walletseq_account_time`;
ALTER TABLE `planstar_community`.`reviews` DROP INDEX `idx_review_act_time`;
ALTER TABLE `planstar_community`.`feeds` DROP INDEX `idx_feed_addtime_id`;
ALTER TABLE `planstar_community`.`feeds` ADD INDEX `idx_feed_addtime` (`add_time`);

-- EOF
