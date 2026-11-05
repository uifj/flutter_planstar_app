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
