-- ========================================================================
--  sql_new（已修复版）· drop_optional_fks.sql
--  来源: docs/sql/drop_optional_fks.sql  |  生成: tools/build_sql_new.py
--  与基线的差异:
--    R1 表尾显式 COLLATE=utf8mb4_unicode_ci（库/表/列三层排序规则统一）
--    R2 8 处关联 ID 由 INT 对齐为 BIGINT（消除 fk_pin_tuan_orders_pin_tuan_id 阻塞）
--    R3 4 处元数据代理主键补 COMMENT
--  为什么这样设计: 以上三项不改变列语义、不拒绝历史数据、不影响 267 个 REST 契约，
--    属于可确定性执行的规范类修复；会改变业务口径的提案全部留在 optional/PROPOSALS.sql。
--  基线 docs/sql/ 未被修改；本目录可独立用于 MySQL 8.0 全新空库安装。
--  验证边界: 见 VALIDATION.md（未做真实 MySQL 8.0 执行 / EXPLAIN / 压测 / HA 验证）。
-- ========================================================================
--  回滚 12_constraints.sql 的 61 条推断外键。

-- =======================================================================
--  Planstar 数据库评审 · 候选优化迁移
--  目标：MySQL 8.0 / InnoDB / utf8mb4 / 全新空库演示环境
--  生成：generate_review_sql.py（读取 01..11 根 DDL，不修改 000001 基线）
--  方言：MySQL 8.0。所有 DDL 均隐式提交，回滚依赖本包的 .down.sql 补偿脚本。
--  重要：本文件不是「已验证的性能优化」，索引项均为条件候选，
--        上线前必须用真实 EXPLAIN / 慢查询日志验证。
-- =======================================================================

-- helpers/drop_optional_fks.sql
-- 用途：回滚 000002 之前先移除 12_constraints.sql 安装的推断外键。
-- 原因：ALTER TABLE MODIFY COLUMN 不能改被外键引用的列类型；
--       CONVERT TO CHARACTER SET 在父子表分别执行时也可能与外键冲突。
-- 说明：12_constraints.sql 的 61 条外键全部是【按字段名推断】，不是真实库导出；
--       删除它们不丢失业务数据，只移除数据库级引用完整性检查。
-- 重建：重新执行 ../../12_constraints.sql（需先跑 000002 修复 INT/BIGINT）。
-- -----------------------------------------------------------------------

ALTER TABLE `planstar_user`.`login_sessions` DROP FOREIGN KEY `fk_login_sessions_user_id`;
ALTER TABLE `planstar_user`.`real_name_infos` DROP FOREIGN KEY `fk_real_name_infos_user_id`;
ALTER TABLE `planstar_user`.`user_addresses` DROP FOREIGN KEY `fk_user_addresses_user_id`;
ALTER TABLE `planstar_user`.`user_follows` DROP FOREIGN KEY `fk_user_follows_user_id`;
ALTER TABLE `planstar_user`.`user_statistics` DROP FOREIGN KEY `fk_user_statistics_user_id`;
ALTER TABLE `planstar_user`.`user_messages` DROP FOREIGN KEY `fk_user_messages_user_id`;
ALTER TABLE `planstar_user`.`chat_threads` DROP FOREIGN KEY `fk_chat_threads_user_id`;
ALTER TABLE `planstar_user`.`chat_messages` DROP FOREIGN KEY `fk_chat_messages_thread_id`;
ALTER TABLE `planstar_catalog`.`venues` DROP FOREIGN KEY `fk_venues_city_id`;
ALTER TABLE `planstar_catalog`.`activities` DROP FOREIGN KEY `fk_activities_city_id`;
ALTER TABLE `planstar_catalog`.`activities` DROP FOREIGN KEY `fk_activities_venue_id`;
ALTER TABLE `planstar_catalog`.`activity_events` DROP FOREIGN KEY `fk_activity_events_activity_id`;
ALTER TABLE `planstar_catalog`.`activity_details` DROP FOREIGN KEY `fk_activity_details_activity_id`;
ALTER TABLE `planstar_catalog`.`activity_lineups` DROP FOREIGN KEY `fk_activity_lineups_activity_id`;
ALTER TABLE `planstar_catalog`.`activity_galleries` DROP FOREIGN KEY `fk_activity_galleries_activity_id`;
ALTER TABLE `planstar_catalog`.`activity_refund_policies` DROP FOREIGN KEY `fk_activity_refund_policies_activity_id`;
ALTER TABLE `planstar_catalog`.`activity_refund_rule_details` DROP FOREIGN KEY `fk_activity_refund_rule_details_rule_id`;
ALTER TABLE `planstar_catalog`.`activity_campaigns` DROP FOREIGN KEY `fk_activity_campaigns_activity_id`;
ALTER TABLE `planstar_catalog`.`tours` DROP FOREIGN KEY `fk_tours_actor_id`;
ALTER TABLE `planstar_ticket`.`ticket_categories` DROP FOREIGN KEY `fk_ticket_categories_activity_event_id`;
ALTER TABLE `planstar_ticket`.`ticket_groups` DROP FOREIGN KEY `fk_ticket_groups_ticket_category_id`;
ALTER TABLE `planstar_ticket`.`ticket_seats` DROP FOREIGN KEY `fk_ticket_seats_area_id`;
ALTER TABLE `planstar_order`.`orders` DROP FOREIGN KEY `fk_orders_user_id`;
ALTER TABLE `planstar_order`.`orders` DROP FOREIGN KEY `fk_orders_activity_id`;
ALTER TABLE `planstar_order`.`order_events` DROP FOREIGN KEY `fk_order_events_order_id`;
ALTER TABLE `planstar_order`.`order_items` DROP FOREIGN KEY `fk_order_items_order_id`;
ALTER TABLE `planstar_order`.`order_goods` DROP FOREIGN KEY `fk_order_goods_order_id`;
ALTER TABLE `planstar_order`.`order_goods_packages` DROP FOREIGN KEY `fk_order_goods_packages_order_id`;
ALTER TABLE `planstar_order`.`order_deliveries` DROP FOREIGN KEY `fk_order_deliveries_order_id`;
ALTER TABLE `planstar_order`.`order_confirm_snapshots` DROP FOREIGN KEY `fk_order_confirm_snapshots_order_id`;
ALTER TABLE `planstar_payment`.`payments` DROP FOREIGN KEY `fk_payments_order_id`;
ALTER TABLE `planstar_payment`.`payment_channels` DROP FOREIGN KEY `fk_payment_channels_pay_id`;
ALTER TABLE `planstar_payment`.`refunds` DROP FOREIGN KEY `fk_refunds_order_id`;
ALTER TABLE `planstar_order`.`order_postage` DROP FOREIGN KEY `fk_order_postage_order_id`;
ALTER TABLE `planstar_order`.`order_comments` DROP FOREIGN KEY `fk_order_comments_order_id`;
ALTER TABLE `planstar_marketing`.`coupons` DROP FOREIGN KEY `fk_coupons_user_id`;
ALTER TABLE `planstar_payment`.`gift_cards` DROP FOREIGN KEY `fk_gift_cards_user_id`;
ALTER TABLE `planstar_payment`.`gift_card_usages` DROP FOREIGN KEY `fk_gift_card_usages_order_id`;
ALTER TABLE `planstar_payment`.`gift_card_usages` DROP FOREIGN KEY `fk_gift_card_usages_gift_card_id`;
ALTER TABLE `planstar_payment`.`wallet_accounts` DROP FOREIGN KEY `fk_wallet_accounts_user_id`;
ALTER TABLE `planstar_payment`.`wallet_sequences` DROP FOREIGN KEY `fk_wallet_sequences_account_id`;
ALTER TABLE `planstar_marketing`.`pin_tuan_campaigns` DROP FOREIGN KEY `fk_pin_tuan_campaigns_activity_id`;
ALTER TABLE `planstar_marketing`.`pin_tuan_campaign_items` DROP FOREIGN KEY `fk_pin_tuan_campaign_items_pin_tuan_id`;
ALTER TABLE `planstar_marketing`.`pin_tuan_orders` DROP FOREIGN KEY `fk_pin_tuan_orders_pin_tuan_id`;
ALTER TABLE `planstar_marketing`.`group_buy_members` DROP FOREIGN KEY `fk_group_buy_members_group_id`;
ALTER TABLE `planstar_marketing`.`proxy_buy_configs` DROP FOREIGN KEY `fk_proxy_buy_configs_activity_id`;
ALTER TABLE `planstar_marketing`.`to_watch` DROP FOREIGN KEY `fk_to_watch_user_id`;
ALTER TABLE `planstar_marketing`.`favorites` DROP FOREIGN KEY `fk_favorites_user_id`;
ALTER TABLE `planstar_marketing`.`favorites` DROP FOREIGN KEY `fk_favorites_activity_id`;
ALTER TABLE `planstar_community`.`reviews` DROP FOREIGN KEY `fk_reviews_user_id`;
ALTER TABLE `planstar_community`.`reviews` DROP FOREIGN KEY `fk_reviews_activity_id`;
ALTER TABLE `planstar_community`.`review_replies` DROP FOREIGN KEY `fk_review_replies_review_id`;
ALTER TABLE `planstar_community`.`review_todos` DROP FOREIGN KEY `fk_review_todos_user_id`;
ALTER TABLE `planstar_community`.`feeds` DROP FOREIGN KEY `fk_feeds_user_id`;
ALTER TABLE `planstar_community`.`feed_media` DROP FOREIGN KEY `fk_feed_media_feed_id`;
ALTER TABLE `planstar_community`.`user_articles` DROP FOREIGN KEY `fk_user_articles_user_id`;
ALTER TABLE `planstar_community`.`likes` DROP FOREIGN KEY `fk_likes_user_id`;
ALTER TABLE `planstar_marketing`.`transfers` DROP FOREIGN KEY `fk_transfers_user_id`;
ALTER TABLE `planstar_content`.`share_logs` DROP FOREIGN KEY `fk_share_logs_user_id`;
ALTER TABLE `planstar_content`.`feedback` DROP FOREIGN KEY `fk_feedback_user_id`;
ALTER TABLE `planstar_content`.`tracking_events` DROP FOREIGN KEY `fk_tracking_events_user_id`;

-- EOF
