-- ========================================================================
--  migrations/planstar_community/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `video_channels`;
DROP TABLE IF EXISTS `likes`;
DROP TABLE IF EXISTS `user_articles`;
DROP TABLE IF EXISTS `communities`;
DROP TABLE IF EXISTS `topics`;
DROP TABLE IF EXISTS `feed_media`;
DROP TABLE IF EXISTS `feeds`;
DROP TABLE IF EXISTS `review_todos`;
DROP TABLE IF EXISTS `review_replies`;
DROP TABLE IF EXISTS `reviews`;

SET FOREIGN_KEY_CHECKS = 1;
