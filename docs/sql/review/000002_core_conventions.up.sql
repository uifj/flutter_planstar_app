-- =======================================================================
--  Planstar 数据库评审 · 候选优化迁移
--  目标：MySQL 8.0 / InnoDB / utf8mb4 / 全新空库演示环境
--  生成：generate_review_sql.py（读取 01..11 根 DDL，不修改 000001 基线）
--  方言：MySQL 8.0。所有 DDL 均隐式提交，回滚依赖本包的 .down.sql 补偿脚本。
--  重要：本文件不是「已验证的性能优化」，索引项均为条件候选，
--        上线前必须用真实 EXPLAIN / 慢查询日志验证。
-- =======================================================================

-- -----------------------------------------------------------------------
-- A. 统一排序规则：表级 utf8mb4（无 COLLATE）→ 显式 utf8mb4_unicode_ci
--    事实：9 个库显式 COLLATE utf8mb4_unicode_ci；89 张表只写 CHARSET=utf8mb4，
--    MySQL 8.0 会取字符集默认 utf8mb4_0900_ai_ci（NO PAD），与库默认（PAD SPACE）不一致。
--    438 个字符列继承表默认。CONVERT TO 会重建表并显式设置列排序规则。
--    执行顺序：必须在 12_constraints.sql 之前；若已建外键，先跑 helpers/drop_optional_fks.sql。
-- -----------------------------------------------------------------------

ALTER TABLE `planstar_user`.`users` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`login_sessions` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`real_name_infos` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`user_addresses` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`user_follows` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`user_statistics` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`user_messages` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`chat_threads` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_user`.`chat_messages` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`cities` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`country_areas` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`venues` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_categories` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_sub_tags` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`app_configs` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`app_versions` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activities` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_events` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_details` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_lineups` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_galleries` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_refund_policies` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_refund_rules` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_refund_rule_details` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_refund_relations` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_campaigns` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`activity_subjects` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`actors` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`actor_qr_codes` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`tours` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`shops` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_catalog`.`organizers` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_ticket`.`ticket_categories` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_ticket`.`ticket_groups` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_ticket`.`ticket_areas` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_ticket`.`ticket_seats` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_ticket`.`seat_map_layouts` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_ticket`.`discount_activities` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`orders` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_events` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_items` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_goods` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_goods_packages` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_deliveries` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_confirm_snapshots` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_postage` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`order_comments` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_order`.`speed_packs` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_payment`.`payments` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_payment`.`payment_channels` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_payment`.`refunds` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_payment`.`wallet_accounts` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_payment`.`wallet_sequences` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_payment`.`gift_cards` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_payment`.`gift_card_usages` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`coupons` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`campaigns` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`coupon_packages` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`pin_tuan_campaigns` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`pin_tuan_campaign_items` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`pin_tuan_orders` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`group_buy_members` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`proxy_buy_configs` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`proxy_buy_orders` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`transfers` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`to_watch` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_marketing`.`favorites` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`reviews` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`review_replies` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`review_todos` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`feeds` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`feed_media` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`topics` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`communities` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`user_articles` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`likes` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_community`.`video_channels` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`banners` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`ads` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`home_floors` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`op_positions` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`search_keywords` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`share_logs` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`feedback` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_content`.`tracking_events` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_meta`.`dict_enums` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_meta`.`_rev_dto_field_catalog` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_meta`.`_rev_endpoint_catalog` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `planstar_meta`.`_rev_dto_table_mapping` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------
-- B. 关联字段类型对齐 INT → BIGINT（Alibaba：关联字段数据类型必须绝对一致）
--    P0：pin_tuan_orders.pin_tuan_id 是 12_constraints.sql 第 55 行的 FK
--    「INT → BIGINT」不兼容，会让全新安装在此处报错并留下 43/61 条半安装外键。
--    其余 7 处虽未声明 FK，但与 BIGINT 主键语义关联，一并对齐。
--    不处理 actor_qr_codes.actor_id VARCHAR(64)：可能存非数字 QR token，需业务确认。
-- -----------------------------------------------------------------------

-- planstar_marketing.pin_tuan_orders.pin_tuan_id  ← planstar_marketing.pin_tuan_campaigns.id
ALTER TABLE `planstar_marketing`.`pin_tuan_orders` MODIFY COLUMN `pin_tuan_id` BIGINT COMMENT '拼团活动ID | PinTuanOrderRequestBody.pinTuanId';
-- planstar_marketing.pin_tuan_orders.pin_tuan_campaign_item_id  ← planstar_marketing.pin_tuan_campaign_items.id
ALTER TABLE `planstar_marketing`.`pin_tuan_orders` MODIFY COLUMN `pin_tuan_campaign_item_id` BIGINT COMMENT '拼团项ID | PinTuanOrderRequestBody.pinTuanCampaignItemId';
-- planstar_order.orders.pin_tuan_id  ← planstar_marketing.pin_tuan_campaigns.id
ALTER TABLE `planstar_order`.`orders` MODIFY COLUMN `pin_tuan_id` BIGINT COMMENT '拼团ID | MakeOrderRequestBody.pinTuanId';
-- planstar_order.speed_packs.pin_tuan_id  ← planstar_marketing.pin_tuan_campaigns.id
ALTER TABLE `planstar_order`.`speed_packs` MODIFY COLUMN `pin_tuan_id` BIGINT COMMENT '拼团ID | BizParam.pinTuanId';
-- planstar_catalog.activity_events.ticket_group_id  ← planstar_ticket.ticket_groups.id
ALTER TABLE `planstar_catalog`.`activity_events` MODIFY COLUMN `ticket_group_id` BIGINT COMMENT '票组ID | ActivityEventBean.ticketGroupId';
-- planstar_ticket.ticket_groups.pin_tuan_campaign_item_id  ← planstar_marketing.pin_tuan_campaign_items.id
ALTER TABLE `planstar_ticket`.`ticket_groups` MODIFY COLUMN `pin_tuan_campaign_item_id` BIGINT COMMENT '拼团项ID | TicketGroup.pinTuanCampaignItemId';
-- planstar_marketing.coupons.activity_event_id  ← planstar_catalog.activity_events.id
ALTER TABLE `planstar_marketing`.`coupons` MODIFY COLUMN `activity_event_id` BIGINT COMMENT '适用场次 | Coupon.activityEventId';
-- planstar_marketing.pin_tuan_campaigns.shop_id  ← planstar_catalog.shops.shop_id
ALTER TABLE `planstar_marketing`.`pin_tuan_campaigns` MODIFY COLUMN `shop_id` BIGINT COMMENT '店铺ID | PinTuanInfo.shopId';

-- -----------------------------------------------------------------------
-- C. 补齐 4 个元数据代理主键的列注释（ISO/IEC 11179 数据元可解释性 / Alibaba 注释规约）
-- -----------------------------------------------------------------------

ALTER TABLE `planstar_meta`.`dict_enums` MODIFY COLUMN `id` INT NOT NULL AUTO_INCREMENT COMMENT '字典自增代理主键（非业务 ID）';
ALTER TABLE `planstar_meta`.`_rev_dto_field_catalog` MODIFY COLUMN `id` INT NOT NULL AUTO_INCREMENT COMMENT 'DTO 字段证据自增代理主键';
ALTER TABLE `planstar_meta`.`_rev_endpoint_catalog` MODIFY COLUMN `id` INT NOT NULL AUTO_INCREMENT COMMENT '端点证据自增代理主键';
ALTER TABLE `planstar_meta`.`_rev_dto_table_mapping` MODIFY COLUMN `id` INT NOT NULL AUTO_INCREMENT COMMENT 'DTO 映射证据自增代理主键';

-- EOF
