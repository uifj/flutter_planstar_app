-- ========================================================================
--  sql_new（已修复版）· planstar_marketing/000001_init.down.sql
--  来源: docs/sql/planstar_marketing/000001_init.down.sql  |  生成: tools/build_sql_new.py
--  与基线的差异:
--    R1 表尾显式 COLLATE=utf8mb4_unicode_ci（库/表/列三层排序规则统一）
--    R2 8 处关联 ID 由 INT 对齐为 BIGINT（消除 fk_pin_tuan_orders_pin_tuan_id 阻塞）
--    R3 4 处元数据代理主键补 COMMENT
--  为什么这样设计: 以上三项不改变列语义、不拒绝历史数据、不影响 267 个 REST 契约，
--    属于可确定性执行的规范类修复；会改变业务口径的提案全部留在 optional/PROPOSALS.sql。
--  基线 docs/sql/ 未被修改；本目录可独立用于 MySQL 8.0 全新空库安装。
--  验证边界: 见 VALIDATION.md（未做真实 MySQL 8.0 执行 / EXPLAIN / 压测 / HA 验证）。
-- ========================================================================

-- ========================================================================
--  migrations/planstar_marketing/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `favorites`;
DROP TABLE IF EXISTS `to_watch`;
DROP TABLE IF EXISTS `transfers`;
DROP TABLE IF EXISTS `proxy_buy_orders`;
DROP TABLE IF EXISTS `proxy_buy_configs`;
DROP TABLE IF EXISTS `group_buy_members`;
DROP TABLE IF EXISTS `pin_tuan_orders`;
DROP TABLE IF EXISTS `pin_tuan_campaign_items`;
DROP TABLE IF EXISTS `pin_tuan_campaigns`;
DROP TABLE IF EXISTS `coupon_packages`;
DROP TABLE IF EXISTS `campaigns`;
DROP TABLE IF EXISTS `coupons`;

SET FOREIGN_KEY_CHECKS = 1;
