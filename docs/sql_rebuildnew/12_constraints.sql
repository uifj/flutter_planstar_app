-- ========================================================================
--  sql_rebuildnew · 12_constraints.sql
--  来源  : docs/sql_new（已含 R1 显式 COLLATE / R2 8 处 BIGINT 对齐 / R3 4 处注释）
--  用途  : 在真实 MySQL（Docker 镜像 8dbcf531a03a，mysql:8 / 8.4.10 LTS）上完整实跑验证。
--  与 sql_new 的差异:
--     (a) 替换 sql_new 中「未做真实 MySQL 执行」的过时生成头部；
--     (b) R4 确定性规范修复：TINYINT(1) -> TINYINT，消除 MySQL 8.4 的 1681
--         「整数显示宽度已弃用」告警。显示宽度不影响存储、值域、可空性、默认值，
--         本库经 JSON REST 访问、无 JDBC tinyInt1isBit 依赖，故语义等价。
--  原样版本（未做 R4，119 条 1681 告警）见 00_all_faithful.sql。
--  未执行 deep_review 的 P01–P17 语义提案（Q1–Q10 未确认）。
--  实跑结果: 见 VALIDATION.md / validation.json / run_log_clean.txt
-- ========================================================================

-- ========================================================================
--  12_constraints.sql · 推断外键 / 校验查询 / 落地建议
-- ========================================================================
--  ⚠ 以下 61 条外键全部是【按字段名与业务语义推断】的，不是从真实库导出的。
--  ⚠ 本重构按服务拆库后，绝大多数外键是【跨库】的：
--      MySQL InnoDB 支持 `库`.`表` 形式的跨库外键，但要求所有库在同一实例；
--      真实微服务落地通常【不建物理外键】、改由应用层保证一致性。
--      若只想要建表、不想要约束，跳过本文件即可（不影响 01–11 执行）。
--  所有表都已用所属服务库完全限定，因此本文件不依赖 USE 的当前库。
-- ========================================================================

ALTER TABLE `planstar_user`.`login_sessions` ADD CONSTRAINT `fk_login_sessions_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_user`.`real_name_infos` ADD CONSTRAINT `fk_real_name_infos_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_user`.`user_addresses` ADD CONSTRAINT `fk_user_addresses_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_user`.`user_follows` ADD CONSTRAINT `fk_user_follows_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_user`.`user_statistics` ADD CONSTRAINT `fk_user_statistics_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_user`.`user_messages` ADD CONSTRAINT `fk_user_messages_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_user`.`chat_threads` ADD CONSTRAINT `fk_chat_threads_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_user`.`chat_messages` ADD CONSTRAINT `fk_chat_messages_thread_id` FOREIGN KEY (`thread_id`) REFERENCES `planstar_user`.`chat_threads` (`thread_id`);
ALTER TABLE `planstar_catalog`.`venues` ADD CONSTRAINT `fk_venues_city_id` FOREIGN KEY (`city_id`) REFERENCES `planstar_catalog`.`cities` (`city_id`);
ALTER TABLE `planstar_catalog`.`activities` ADD CONSTRAINT `fk_activities_city_id` FOREIGN KEY (`city_id`) REFERENCES `planstar_catalog`.`cities` (`city_id`);
ALTER TABLE `planstar_catalog`.`activities` ADD CONSTRAINT `fk_activities_venue_id` FOREIGN KEY (`venue_id`) REFERENCES `planstar_catalog`.`venues` (`venue_id`);
ALTER TABLE `planstar_catalog`.`activity_events` ADD CONSTRAINT `fk_activity_events_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_catalog`.`activity_details` ADD CONSTRAINT `fk_activity_details_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_catalog`.`activity_lineups` ADD CONSTRAINT `fk_activity_lineups_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_catalog`.`activity_galleries` ADD CONSTRAINT `fk_activity_galleries_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_catalog`.`activity_refund_policies` ADD CONSTRAINT `fk_activity_refund_policies_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_catalog`.`activity_refund_rule_details` ADD CONSTRAINT `fk_activity_refund_rule_details_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `planstar_catalog`.`activity_refund_rules` (`id`);
ALTER TABLE `planstar_catalog`.`activity_campaigns` ADD CONSTRAINT `fk_activity_campaigns_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_catalog`.`tours` ADD CONSTRAINT `fk_tours_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `planstar_catalog`.`actors` (`id`);
ALTER TABLE `planstar_ticket`.`ticket_categories` ADD CONSTRAINT `fk_ticket_categories_activity_event_id` FOREIGN KEY (`activity_event_id`) REFERENCES `planstar_catalog`.`activity_events` (`id`);
ALTER TABLE `planstar_ticket`.`ticket_groups` ADD CONSTRAINT `fk_ticket_groups_ticket_category_id` FOREIGN KEY (`ticket_category_id`) REFERENCES `planstar_ticket`.`ticket_categories` (`id`);
ALTER TABLE `planstar_ticket`.`ticket_seats` ADD CONSTRAINT `fk_ticket_seats_area_id` FOREIGN KEY (`area_id`) REFERENCES `planstar_ticket`.`ticket_areas` (`id`);
ALTER TABLE `planstar_order`.`orders` ADD CONSTRAINT `fk_orders_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_order`.`orders` ADD CONSTRAINT `fk_orders_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_order`.`order_events` ADD CONSTRAINT `fk_order_events_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_order`.`order_items` ADD CONSTRAINT `fk_order_items_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_order`.`order_goods` ADD CONSTRAINT `fk_order_goods_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_order`.`order_goods_packages` ADD CONSTRAINT `fk_order_goods_packages_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_order`.`order_deliveries` ADD CONSTRAINT `fk_order_deliveries_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_order`.`order_confirm_snapshots` ADD CONSTRAINT `fk_order_confirm_snapshots_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_payment`.`payments` ADD CONSTRAINT `fk_payments_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_payment`.`payment_channels` ADD CONSTRAINT `fk_payment_channels_pay_id` FOREIGN KEY (`pay_id`) REFERENCES `planstar_payment`.`payments` (`pay_id`);
ALTER TABLE `planstar_payment`.`refunds` ADD CONSTRAINT `fk_refunds_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_order`.`order_postage` ADD CONSTRAINT `fk_order_postage_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_order`.`order_comments` ADD CONSTRAINT `fk_order_comments_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_marketing`.`coupons` ADD CONSTRAINT `fk_coupons_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_payment`.`gift_cards` ADD CONSTRAINT `fk_gift_cards_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_payment`.`gift_card_usages` ADD CONSTRAINT `fk_gift_card_usages_order_id` FOREIGN KEY (`order_id`) REFERENCES `planstar_order`.`orders` (`order_id`);
ALTER TABLE `planstar_payment`.`gift_card_usages` ADD CONSTRAINT `fk_gift_card_usages_gift_card_id` FOREIGN KEY (`gift_card_id`) REFERENCES `planstar_payment`.`gift_cards` (`id`);
ALTER TABLE `planstar_payment`.`wallet_accounts` ADD CONSTRAINT `fk_wallet_accounts_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_payment`.`wallet_sequences` ADD CONSTRAINT `fk_wallet_sequences_account_id` FOREIGN KEY (`account_id`) REFERENCES `planstar_payment`.`wallet_accounts` (`account_id`);
ALTER TABLE `planstar_marketing`.`pin_tuan_campaigns` ADD CONSTRAINT `fk_pin_tuan_campaigns_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_marketing`.`pin_tuan_campaign_items` ADD CONSTRAINT `fk_pin_tuan_campaign_items_pin_tuan_id` FOREIGN KEY (`pin_tuan_id`) REFERENCES `planstar_marketing`.`pin_tuan_campaigns` (`id`);
--  [sql_new] F-01 阻塞已由 R2 消除：子列 pin_tuan_orders.pin_tuan_id 现为 BIGINT，
--  与父列 pin_tuan_campaigns.id BIGINT 一致，本条约束不再因类型不匹配中断。
ALTER TABLE `planstar_marketing`.`pin_tuan_orders` ADD CONSTRAINT `fk_pin_tuan_orders_pin_tuan_id` FOREIGN KEY (`pin_tuan_id`) REFERENCES `planstar_marketing`.`pin_tuan_campaigns` (`id`);
ALTER TABLE `planstar_marketing`.`group_buy_members` ADD CONSTRAINT `fk_group_buy_members_group_id` FOREIGN KEY (`group_id`) REFERENCES `planstar_marketing`.`pin_tuan_campaigns` (`id`);
ALTER TABLE `planstar_marketing`.`proxy_buy_configs` ADD CONSTRAINT `fk_proxy_buy_configs_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_marketing`.`to_watch` ADD CONSTRAINT `fk_to_watch_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_marketing`.`favorites` ADD CONSTRAINT `fk_favorites_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_marketing`.`favorites` ADD CONSTRAINT `fk_favorites_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_community`.`reviews` ADD CONSTRAINT `fk_reviews_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_community`.`reviews` ADD CONSTRAINT `fk_reviews_activity_id` FOREIGN KEY (`activity_id`) REFERENCES `planstar_catalog`.`activities` (`id`);
ALTER TABLE `planstar_community`.`review_replies` ADD CONSTRAINT `fk_review_replies_review_id` FOREIGN KEY (`review_id`) REFERENCES `planstar_community`.`reviews` (`id`);
ALTER TABLE `planstar_community`.`review_todos` ADD CONSTRAINT `fk_review_todos_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_community`.`feeds` ADD CONSTRAINT `fk_feeds_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_community`.`feed_media` ADD CONSTRAINT `fk_feed_media_feed_id` FOREIGN KEY (`feed_id`) REFERENCES `planstar_community`.`feeds` (`id`);
ALTER TABLE `planstar_community`.`user_articles` ADD CONSTRAINT `fk_user_articles_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_community`.`likes` ADD CONSTRAINT `fk_likes_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_marketing`.`transfers` ADD CONSTRAINT `fk_transfers_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_content`.`share_logs` ADD CONSTRAINT `fk_share_logs_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_content`.`feedback` ADD CONSTRAINT `fk_feedback_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);
ALTER TABLE `planstar_content`.`tracking_events` ADD CONSTRAINT `fk_tracking_events_user_id` FOREIGN KEY (`user_id`) REFERENCES `planstar_user`.`users` (`user_id`);

--  校验查询需先 USE 对应服务库（dict_enums / _rev_* 在 planstar_meta）。


-- ---------------------------------------------------------------------------
--  校验查询（建完后执行，确认覆盖率）
-- ---------------------------------------------------------------------------
-- 1) 表数量（业务表 + 证据表 + 字典表；SDK 表已移除）
-- SELECT COUNT(*) AS table_count FROM information_schema.tables
--   WHERE table_schema = DATABASE();
-- 2) 逆向到的 DTO 字段总数 / 唯一字段名数
-- SELECT COUNT(*) AS field_rows, COUNT(DISTINCT field_name) AS unique_fields
--   FROM `_rev_dto_field_catalog`;
-- 3) 端点总数 / 按 HTTP 方法分布
-- SELECT http_method, COUNT(*) FROM `_rev_endpoint_catalog` GROUP BY http_method;
-- 4) 枚举字典分布
-- SELECT enum_name, COUNT(*) FROM `dict_enums` GROUP BY enum_name ORDER BY enum_name;
-- 5) 未落表的 DTO（需要人工确认是否补表）
-- SELECT dto_class, representation FROM `_rev_dto_table_mapping`
--   WHERE representation LIKE '%不单独建表%' OR representation LIKE '%内嵌对象%';
--
-- 落地建议：
--   a) 先拿真实库 information_schema 对齐表名 / 列名 / 类型，尤其是 DECIMAL 精度；
--   b) 时间字段若是 DATETIME，用 FROM_UNIXTIME(col/1000) 做一次迁移校验；
--   c) 状态类字段务必对照 dict_enums：OrderStatus 与 OrderUtils 前 4 个状态差 1，
--      WAITING_FOR_TICKETS 的描述还是从 INIT 复制错的（wiki_zh/27 §11.1）；
--   d) 94 个 DTO 的 ID 是 Java int，超过 2^31 会溢出（wiki_zh/27 §10），
--      本 schema 已放宽为 BIGINT；
--   e) ActivityBean.id 与 activityId 是两个独立字段，服务端有时只填其中一个，
--      导入时务必做 COALESCE 归一；
--   f) MakeOrderRequestBody.channelAttributeInfo 是自嵌套 JSON 字符串，
--      couponIds 与 campaignIds 互斥，giftCards 带实际抵扣额。

-- ========================================================================
--  EOF
-- ========================================================================
