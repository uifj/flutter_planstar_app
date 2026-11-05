-- ========================================================================
--  sql_new（已修复版）· 13_query_indexes.down.sql
--  来源: docs/sql/13_query_indexes.down.sql  |  生成: tools/build_sql_new.py
--  与基线的差异:
--    R1 表尾显式 COLLATE=utf8mb4_unicode_ci（库/表/列三层排序规则统一）
--    R2 8 处关联 ID 由 INT 对齐为 BIGINT（消除 fk_pin_tuan_orders_pin_tuan_id 阻塞）
--    R3 4 处元数据代理主键补 COMMENT
--  为什么这样设计: 以上三项不改变列语义、不拒绝历史数据、不影响 267 个 REST 契约，
--    属于可确定性执行的规范类修复；会改变业务口径的提案全部留在 optional/PROPOSALS.sql。
--  基线 docs/sql/ 未被修改；本目录可独立用于 MySQL 8.0 全新空库安装。
--  验证边界: 见 VALIDATION.md（未做真实 MySQL 8.0 执行 / EXPLAIN / 压测 / HA 验证）。
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
