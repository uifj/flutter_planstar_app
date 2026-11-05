-- ========================================================================
--  migrations/planstar_catalog/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `organizers`;
DROP TABLE IF EXISTS `shops`;
DROP TABLE IF EXISTS `tours`;
DROP TABLE IF EXISTS `actor_qr_codes`;
DROP TABLE IF EXISTS `actors`;
DROP TABLE IF EXISTS `activity_subjects`;
DROP TABLE IF EXISTS `activity_campaigns`;
DROP TABLE IF EXISTS `activity_refund_relations`;
DROP TABLE IF EXISTS `activity_refund_rule_details`;
DROP TABLE IF EXISTS `activity_refund_rules`;
DROP TABLE IF EXISTS `activity_refund_policies`;
DROP TABLE IF EXISTS `activity_galleries`;
DROP TABLE IF EXISTS `activity_lineups`;
DROP TABLE IF EXISTS `activity_details`;
DROP TABLE IF EXISTS `activity_events`;
DROP TABLE IF EXISTS `activities`;
DROP TABLE IF EXISTS `app_versions`;
DROP TABLE IF EXISTS `app_configs`;
DROP TABLE IF EXISTS `activity_sub_tags`;
DROP TABLE IF EXISTS `activity_categories`;
DROP TABLE IF EXISTS `venues`;
DROP TABLE IF EXISTS `country_areas`;
DROP TABLE IF EXISTS `cities`;

SET FOREIGN_KEY_CHECKS = 1;
