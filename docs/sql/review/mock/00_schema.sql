-- =======================================================================
--  Planstar 票务 Mock · 隔离库 DDL
--  目标库：planstar_mock_ticketing（与 9 个业务库完全隔离，可整体 DROP）
--  方言：MySQL 8.0；同时刻意使用 SQLite 也可执行的便携子集，
--        以便 validate_review.py 能在没有 MySQL 引擎时做真实 SQL 加载校验。
--
--  与 mall 样例的对应关系（只借「场景形态」，不复制任何真实数据）：
--    cms_help_category / cms_help          → help_categories / help
--    cms_member_report（原表无主键）        → member_reports（本 mock 补主键）
--    oms_cart_item（重复 SKU / 空价格 / 逻辑删除）→ cart_items
--    oms_company_address                  → user_addresses（虚构收件信息）
--    oms_order（多状态 / 多配送方式 / 优惠）  → orders
--    oms_order_item（订单行 / SKU 属性）     → order_items
--  另补票务特有的：场次、票档、区域、座位、支付、退款、券、钱包、礼品卡、
--  拼团、代抢。所有姓名 / 电话 / 地址均为虚构占位值，不含任何真实个人信息。
--
--  口径声明（重要）：
--    * 金额单位统一为「元」DECIMAL(12,2)；Flutter Money 是「分」，需 ×100 适配。
--    * orders.status 使用 dict_enums.OrderStatus（1..7），不使用差 1 的 OrderUtils。
--    * coupons.discount_rate=85 按 Flutter 口径「85 = 85 折」填写；
--      DDL 注释写的「万分比」与 Flutter 冲突，见评审报告 F-07，本 mock 不换算、不参与金额计算。
--    * wallet_sequences.amount 使用有符号金额，与 06_payment.sql 注释一致；
--      Flutter demo 用「正数 + expense 类型」，见评审报告 F-07。
-- =======================================================================

CREATE DATABASE IF NOT EXISTS `planstar_mock_ticketing`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `planstar_mock_ticketing`;

-- ---------------------------------------------------------------- 目录与主档
CREATE TABLE IF NOT EXISTS `cities` (
  `city_id` BIGINT NOT NULL PRIMARY KEY,
  `city_name` VARCHAR(64) NOT NULL,
  `sort_no` INT NOT NULL
);

CREATE TABLE IF NOT EXISTS `venues` (
  `venue_id` BIGINT NOT NULL PRIMARY KEY,
  `city_id` BIGINT NOT NULL,
  `venue_name` VARCHAR(128) NOT NULL,
  `address` VARCHAR(256),
  FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`)
);

CREATE TABLE IF NOT EXISTS `activities` (
  `activity_id` BIGINT NOT NULL PRIMARY KEY,
  `activity_name` VARCHAR(256) NOT NULL,
  `venue_id` BIGINT NOT NULL,
  `category_id` BIGINT,
  `status` INT,
  `start` BIGINT,
  `low_price` DECIMAL(12,2),
  FOREIGN KEY (`venue_id`) REFERENCES `venues` (`venue_id`)
);

CREATE TABLE IF NOT EXISTS `activity_events` (
  `event_id` BIGINT NOT NULL PRIMARY KEY,
  `activity_id` BIGINT NOT NULL,
  `start` BIGINT,
  `end` BIGINT,
  `status` INT,
  `venue_id` BIGINT,
  FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`)
);

CREATE TABLE IF NOT EXISTS `ticket_categories` (
  `category_id` BIGINT NOT NULL PRIMARY KEY,
  `event_id` BIGINT NOT NULL,
  `specification` VARCHAR(128),
  `origin_price` DECIMAL(12,2),
  `sale_price` DECIMAL(12,2),
  `stock` INT,
  `status` INT,
  FOREIGN KEY (`event_id`) REFERENCES `activity_events` (`event_id`)
);

CREATE TABLE IF NOT EXISTS `ticket_areas` (
  `area_id` BIGINT NOT NULL PRIMARY KEY,
  `event_id` BIGINT NOT NULL,
  `area_name` VARCHAR(64),
  FOREIGN KEY (`event_id`) REFERENCES `activity_events` (`event_id`)
);

CREATE TABLE IF NOT EXISTS `ticket_seats` (
  `seat_id` BIGINT NOT NULL PRIMARY KEY,
  `area_id` BIGINT NOT NULL,
  `event_id` BIGINT NOT NULL,
  `seat_row` VARCHAR(16),
  `seat_col` VARCHAR(16),
  `status` INT,
  `price` DECIMAL(12,2),
  FOREIGN KEY (`area_id`) REFERENCES `ticket_areas` (`area_id`)
);

-- ---------------------------------------------------------------- 账号与地址
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` BIGINT NOT NULL PRIMARY KEY,
  `user_name` VARCHAR(64) NOT NULL,
  `mobile_no` VARCHAR(32),
  `status` INT
);

CREATE TABLE IF NOT EXISTS `user_addresses` (
  `address_id` BIGINT NOT NULL PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `receiver_name` VARCHAR(64),
  `phone` VARCHAR(32),
  `detail_address` VARCHAR(256),
  `is_default` INT,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
);

-- ---------------------------------------------------------------- 购物车（mall oms_cart_item 场景）
CREATE TABLE IF NOT EXISTS `cart_items` (
  `cart_id` BIGINT NOT NULL PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `category_id` BIGINT NOT NULL,
  `quantity` INT,
  `price` DECIMAL(12,2),
  `add_time` BIGINT,
  `delete_status` INT,
  `checked` INT,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  FOREIGN KEY (`category_id`) REFERENCES `ticket_categories` (`category_id`)
);

-- ---------------------------------------------------------------- 优惠券
CREATE TABLE IF NOT EXISTS `coupons` (
  `coupon_id` BIGINT NOT NULL PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `title` VARCHAR(128) NOT NULL,
  `discount_type` INT,
  `discount_amount` DECIMAL(12,2),
  `discount_rate` INT,
  `require_amount` DECIMAL(12,2),
  `status` INT,
  `effective_from` BIGINT,
  `effective_to` BIGINT,
  `used_order_id` BIGINT,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
);

-- ---------------------------------------------------------------- 订单与订单行（mall oms_order / oms_order_item 场景）
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` BIGINT NOT NULL PRIMARY KEY,
  `order_number` VARCHAR(64) NOT NULL,
  `user_id` BIGINT NOT NULL,
  `event_id` BIGINT NOT NULL,
  `status` INT,
  `order_type` INT,
  `deliver_type` INT,
  `total_amount` DECIMAL(12,2),
  `discount_amount` DECIMAL(12,2),
  `postage` DECIMAL(12,2),
  `pay_amount` DECIMAL(12,2),
  `coupon_id` BIGINT,
  `address_id` BIGINT,
  `add_time` BIGINT,
  `pay_time` BIGINT,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  FOREIGN KEY (`event_id`) REFERENCES `activity_events` (`event_id`)
);
CREATE UNIQUE INDEX `uk_mock_order_number` ON `orders` (`order_number`);
CREATE INDEX `idx_mock_order_user_addtime` ON `orders` (`user_id`,`add_time`,`order_id`);

CREATE TABLE IF NOT EXISTS `order_items` (
  `item_id` BIGINT NOT NULL PRIMARY KEY,
  `order_id` BIGINT NOT NULL,
  `category_id` BIGINT NOT NULL,
  `seat_id` BIGINT,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(12,2) NOT NULL,
  `line_amount` DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  FOREIGN KEY (`category_id`) REFERENCES `ticket_categories` (`category_id`),
  FOREIGN KEY (`seat_id`) REFERENCES `ticket_seats` (`seat_id`)
);

-- ---------------------------------------------------------------- 支付 / 退款
CREATE TABLE IF NOT EXISTS `payments` (
  `pay_id` BIGINT NOT NULL PRIMARY KEY,
  `order_id` BIGINT NOT NULL,
  `pay_amount` DECIMAL(12,2) NOT NULL,
  `channel` VARCHAR(32),
  `status` VARCHAR(32),
  `provider_trade_no` VARCHAR(64),
  `add_time` BIGINT,
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
);
CREATE UNIQUE INDEX `uk_mock_pay_order` ON `payments` (`order_id`);

CREATE TABLE IF NOT EXISTS `refunds` (
  `refund_id` BIGINT NOT NULL PRIMARY KEY,
  `order_id` BIGINT NOT NULL,
  `refund_amount` DECIMAL(12,2) NOT NULL,
  `reason_code` VARCHAR(32),
  `status` VARCHAR(32),
  `apply_time` BIGINT,
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
);

-- ---------------------------------------------------------------- 钱包（有符号流水）
CREATE TABLE IF NOT EXISTS `wallet_accounts` (
  `account_id` BIGINT NOT NULL PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `balance` DECIMAL(12,2) NOT NULL,
  `status` INT,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
);
CREATE UNIQUE INDEX `uk_mock_wallet_user` ON `wallet_accounts` (`user_id`);

CREATE TABLE IF NOT EXISTS `wallet_sequences` (
  `seq_id` BIGINT NOT NULL PRIMARY KEY,
  `account_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `title` VARCHAR(128),
  `amount` DECIMAL(12,2) NOT NULL,
  `balance_after` DECIMAL(12,2) NOT NULL,
  `type` VARCHAR(16),
  `time` BIGINT,
  FOREIGN KEY (`account_id`) REFERENCES `wallet_accounts` (`account_id`)
);

-- ---------------------------------------------------------------- 礼品卡
CREATE TABLE IF NOT EXISTS `gift_cards` (
  `card_id` BIGINT NOT NULL PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `serial_number` VARCHAR(64) NOT NULL,
  `denomination` DECIMAL(12,2) NOT NULL,
  `balance` DECIMAL(12,2) NOT NULL,
  `status` INT,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
);
CREATE UNIQUE INDEX `uk_mock_gift_serial` ON `gift_cards` (`serial_number`);

CREATE TABLE IF NOT EXISTS `gift_card_usages` (
  `usage_id` BIGINT NOT NULL PRIMARY KEY,
  `card_id` BIGINT NOT NULL,
  `order_id` BIGINT NOT NULL,
  `use_amount` DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (`card_id`) REFERENCES `gift_cards` (`card_id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
);

-- ---------------------------------------------------------------- 拼团 / 代抢
CREATE TABLE IF NOT EXISTS `pin_tuan_campaigns` (
  `campaign_id` BIGINT NOT NULL PRIMARY KEY,
  `activity_id` BIGINT NOT NULL,
  `stock` INT,
  `succeed_num` INT,
  `status` VARCHAR(32),
  FOREIGN KEY (`activity_id`) REFERENCES `activities` (`activity_id`)
);

CREATE TABLE IF NOT EXISTS `group_buy_members` (
  `member_id` BIGINT NOT NULL PRIMARY KEY,
  `campaign_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `is_leader` INT,
  `joined_at` BIGINT,
  FOREIGN KEY (`campaign_id`) REFERENCES `pin_tuan_campaigns` (`campaign_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
);
CREATE UNIQUE INDEX `uk_mock_group_member` ON `group_buy_members` (`campaign_id`,`user_id`);

CREATE TABLE IF NOT EXISTS `proxy_buy_orders` (
  `proxy_id` BIGINT NOT NULL PRIMARY KEY,
  `order_number` VARCHAR(64) NOT NULL,
  `user_id` BIGINT NOT NULL,
  `ticket_price` DECIMAL(12,2) NOT NULL,
  `quantity` INT NOT NULL,
  `proxy_buy_fee` DECIMAL(12,2) NOT NULL,
  `total_amount` DECIMAL(12,2) NOT NULL,
  `status` VARCHAR(32),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
);
CREATE UNIQUE INDEX `uk_mock_proxy_number` ON `proxy_buy_orders` (`order_number`);

-- ---------------------------------------------------------------- 内容/帮助中心（mall cms_* 场景）
CREATE TABLE IF NOT EXISTS `help_categories` (
  `help_category_id` BIGINT NOT NULL PRIMARY KEY,
  `name` VARCHAR(128) NOT NULL
);

CREATE TABLE IF NOT EXISTS `help` (
  `help_id` BIGINT NOT NULL PRIMARY KEY,
  `help_category_id` BIGINT NOT NULL,
  `title` VARCHAR(128) NOT NULL,
  `content` TEXT,
  FOREIGN KEY (`help_category_id`) REFERENCES `help_categories` (`help_category_id`)
);

-- mall 的 cms_member_report 没有主键；这里显式补代理主键（评审发现 F-17）
CREATE TABLE IF NOT EXISTS `member_reports` (
  `report_id` BIGINT NOT NULL PRIMARY KEY,
  `member_nickname` VARCHAR(64),
  `report_type` INT,
  `content` TEXT
);

-- EOF
