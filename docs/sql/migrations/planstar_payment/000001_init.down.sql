-- ========================================================================
--  migrations/planstar_payment/000001_init.down.sql
--  逆序 DROP；先关外键检查，避免 12_constraints.sql 的跨库约束阻塞。
-- ========================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `gift_card_usages`;
DROP TABLE IF EXISTS `gift_cards`;
DROP TABLE IF EXISTS `wallet_sequences`;
DROP TABLE IF EXISTS `wallet_accounts`;
DROP TABLE IF EXISTS `refunds`;
DROP TABLE IF EXISTS `payment_channels`;
DROP TABLE IF EXISTS `payments`;

SET FOREIGN_KEY_CHECKS = 1;
