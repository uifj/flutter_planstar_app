-- ========================================================================
--  migrations/planstar_ticket/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `discount_activities`;
DROP TABLE IF EXISTS `seat_map_layouts`;
DROP TABLE IF EXISTS `ticket_seats`;
DROP TABLE IF EXISTS `ticket_areas`;
DROP TABLE IF EXISTS `ticket_groups`;
DROP TABLE IF EXISTS `ticket_categories`;

SET FOREIGN_KEY_CHECKS = 1;
