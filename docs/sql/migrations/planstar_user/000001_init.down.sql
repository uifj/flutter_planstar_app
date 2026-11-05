-- ========================================================================
--  migrations/planstar_user/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `chat_messages`;
DROP TABLE IF EXISTS `chat_threads`;
DROP TABLE IF EXISTS `user_messages`;
DROP TABLE IF EXISTS `user_statistics`;
DROP TABLE IF EXISTS `user_follows`;
DROP TABLE IF EXISTS `user_addresses`;
DROP TABLE IF EXISTS `real_name_infos`;
DROP TABLE IF EXISTS `login_sessions`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;
