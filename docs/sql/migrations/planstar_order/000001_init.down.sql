-- ========================================================================
--  migrations/planstar_order/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `speed_packs`;
DROP TABLE IF EXISTS `order_comments`;
DROP TABLE IF EXISTS `order_postage`;
DROP TABLE IF EXISTS `order_confirm_snapshots`;
DROP TABLE IF EXISTS `order_deliveries`;
DROP TABLE IF EXISTS `order_goods_packages`;
DROP TABLE IF EXISTS `order_goods`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `order_events`;
DROP TABLE IF EXISTS `orders`;

SET FOREIGN_KEY_CHECKS = 1;
