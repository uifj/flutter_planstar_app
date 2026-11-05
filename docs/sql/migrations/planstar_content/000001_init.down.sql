-- ========================================================================
--  migrations/planstar_content/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `tracking_events`;
DROP TABLE IF EXISTS `feedback`;
DROP TABLE IF EXISTS `share_logs`;
DROP TABLE IF EXISTS `search_keywords`;
DROP TABLE IF EXISTS `op_positions`;
DROP TABLE IF EXISTS `home_floors`;
DROP TABLE IF EXISTS `ads`;
DROP TABLE IF EXISTS `banners`;

SET FOREIGN_KEY_CHECKS = 1;
