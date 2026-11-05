-- ========================================================================
--  migrations/planstar_meta/000001_init.down.sql
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `_rev_dto_table_mapping`;
DROP TABLE IF EXISTS `_rev_endpoint_catalog`;
DROP TABLE IF EXISTS `_rev_dto_field_catalog`;
DROP TABLE IF EXISTS `dict_enums`;

SET FOREIGN_KEY_CHECKS = 1;
