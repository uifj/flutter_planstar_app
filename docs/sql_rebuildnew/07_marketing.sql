-- ========================================================================
--  sql_rebuildnew · 07_marketing.sql
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
--  07 · 营销资产
--  服务库: planstar_marketing
--  执行顺序: 01_init_databases.sql → 02 … 09 → 10 / 11 → 12_constraints.sql
--  本文件 12 张表: coupons, campaigns, coupon_packages, pin_tuan_campaigns, pin_tuan_campaign_items, pin_tuan_orders, group_buy_members, proxy_buy_configs, proxy_buy_orders, transfers, to_watch, favorites
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/tree/main/sql
--    NN_<域>.sql 按服务分库 + migrations/<库>/000001_init.up.sql / .down.sql
--  方言: MySQL 8.0 / InnoDB / utf8mb4（按用户选择保持，未切换 PostgreSQL）
--  第三方 SDK 表（小米推送 / 极光 JPush / 百度定位·mshield / Bugly /
--    字节 AppLog·bdtracker）共 31 张已按要求全部移除。
-- ========================================================================

USE `planstar_marketing`;

-- ----------------------------------------------------------------------
--  域 5 · 营销资产（marketing）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `coupons` (
  `id` BIGINT NOT NULL COMMENT '券ID | Coupon.id',
  `user_id` BIGINT COMMENT '持有用户 | Coupon.userId',
  `order_id` BIGINT COMMENT '使用订单 | Coupon.orderId',
  `activity_id` BIGINT COMMENT '适用演出 | Coupon.activityId',
  `title` VARCHAR(512) COMMENT '券名 | Coupon.title',
  `desc` TEXT COMMENT '说明 | Coupon.desc',
  `discount_type` INT COMMENT '抵扣类型（1 固定金额 / 2 折扣率）| Coupon.discountType / Flutter CouponDiscountType',
  `discount_amount` DECIMAL(12,2) COMMENT '抵扣金额 | Coupon.discountAmount',
  `discount_rate` DECIMAL(10,4) COMMENT '折扣率（万分比口径）| Coupon.discountRate',
  `require_amount` DECIMAL(12,2) COMMENT '使用门槛 | Coupon.requireAmount',
  `effective_time_from` BIGINT COMMENT '生效时间 | Coupon.effectiveTimeFrom',
  `effective_time_to` BIGINT COMMENT '失效时间 | Coupon.effectiveTimeTo',
  `cost_bear_type` INT COMMENT '成本承担方 | Coupon.costBearType',
  `is_can_revoke` TINYINT COMMENT '可撤销 | Coupon.isCanRevoke',
  `is_disable` TINYINT COMMENT '已禁用 | Coupon.isDisable',
  `status` INT COMMENT '状态（可用/已用/过期）| Coupon.status / Flutter CouponStatus',
  `success` TINYINT COMMENT '领取结果 | Coupon.success',
  `source_id` BIGINT COMMENT '来源ID | Coupon.sourceId',
  `source_type` INT COMMENT '来源类型 | Coupon.sourceType',
  `type` INT COMMENT '券类型 | Coupon.type',
  `activity_event_id` BIGINT COMMENT '适用场次 | Coupon.activityEventId',
  `extra_condition` JSON COMMENT '附加条件（原 ExtraConditionBean）| Coupon.extraCondition',
  `data` JSON COMMENT '自嵌套券（原 Coupon data）| Coupon.data',
  `activity_category_ids` JSON COMMENT '适用分类（原 List<Integer>）| Coupon.activityCategoryIds',
  `activity_ids` JSON COMMENT '适用演出（原 List<Integer>）| Coupon.activityIds',
  `client_types` JSON COMMENT '适用客户端（原 List<Integer>）| Coupon.clientTypes',
  `shop_ids` JSON COMMENT '适用店铺（原 List<Integer>）| Coupon.shopIds',
  `add_time` BIGINT COMMENT '创建时间 | Coupon.addTime',
  `update_time` BIGINT COMMENT '更新时间 | Coupon.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_coupon_user` (`user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='优惠券 | Coupon（v1/coupons · POST v1/coupons）+ Flutter Coupon';

CREATE TABLE IF NOT EXISTS `campaigns` (
  `id` BIGINT NOT NULL COMMENT '活动ID | Campaign.id / OrderDiscount.id',
  `title` VARCHAR(512) COMMENT '标题 | Campaign.title',
  `desc` TEXT COMMENT '描述 | Campaign.desc',
  `discount_amount` DECIMAL(12,2) COMMENT '优惠金额 | Campaign.discountAmount / OrderDiscount.discountAmount',
  `background_img` VARCHAR(1024) COMMENT '背景图 | CampaignBean.backgroundImg',
  `content` TEXT COMMENT '内容 | CampaignBean.content',
  `url` VARCHAR(1024) COMMENT '链接 | CampaignBean.url',
  `can_buy` TINYINT COMMENT '可购买 | OrderDiscount.canBuy',
  `can_use_coupon` TINYINT COMMENT '可叠加券 | OrderDiscount.canUseCoupon',
  `error_hint` VARCHAR(1024) COMMENT '错误提示 | OrderDiscount.errorHint',
  `coupons` JSON COMMENT '券列表（原 List<Coupon>）| OrderDiscount.coupons',
  `disable_coupons` JSON COMMENT '不可用券 | OrderDiscount.disableCoupons',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='营销活动 / 折扣 | Campaign / CampaignBean / OrderDiscount';

CREATE TABLE IF NOT EXISTS `coupon_packages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `has_coupon` TINYINT COMMENT '是否有券 | CouponPackageBean.hasCoupon',
  `message` VARCHAR(1024) COMMENT '文案 | CouponPackageBean.message',
  `title` VARCHAR(512) COMMENT '标题 | CouponPackageBean.title',
  `total` INT COMMENT '总数 | CouponPackageBean.total',
  `url` VARCHAR(1024) COMMENT '链接 | CouponPackageBean.url',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='券包 | CouponPackageBean';

CREATE TABLE IF NOT EXISTS `pin_tuan_campaigns` (
  `id` BIGINT NOT NULL COMMENT '拼团活动ID | PinTuanInfo.id',
  `activity_id` BIGINT COMMENT '演出ID | PinTuanInfo.activityId',
  `shop_id` BIGINT COMMENT '店铺ID | PinTuanInfo.shopId',
  `low_price` DECIMAL(12,2) COMMENT '拼团低价 | PinTuanInfo.lowPrice',
  `original_price` DECIMAL(12,2) COMMENT '原价（Flutter）| Flutter GroupBuyInfo.originalPrice',
  `pin_tuan_tag` VARCHAR(256) COMMENT '拼团标签 | PinTuanInfo.pinTuanTag',
  `slogan` VARCHAR(1024) COMMENT '标语 | PinTuanInfo.slogan',
  `stock` INT COMMENT '库存 | PinTuanInfo.stock',
  `succeed_num` INT COMMENT '成团人数 | PinTuanInfo.succeedNum',
  `current_members` INT COMMENT '当前人数（Flutter）| Flutter GroupBuyInfo.currentMembers',
  `is_open` INT COMMENT '是否开启 | PinTuanInfo.isOpen',
  `status` VARCHAR(64) COMMENT '状态（Flutter GroupBuyStatus）| Flutter',
  `show_title` VARCHAR(512) COMMENT '演出名（Flutter）| Flutter GroupBuyInfo.showTitle',
  `venue` VARCHAR(256) COMMENT '场馆（Flutter）| Flutter',
  `event_time` VARCHAR(128) COMMENT '场次时间（Flutter）| Flutter',
  `effective_from` BIGINT COMMENT '生效时间 | PinTuanInfo.effectiveFrom',
  `effective_to` BIGINT COMMENT '失效时间 | PinTuanInfo.effectiveTo',
  `add_time` BIGINT COMMENT '创建时间 | PinTuanInfo.addTime',
  `update_time` BIGINT COMMENT '更新时间 | PinTuanInfo.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_pt_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拼团活动 | PinTuanInfo（GET v1/pinTuanCampaign/{id}）+ Flutter GroupBuyInfo';

CREATE TABLE IF NOT EXISTS `pin_tuan_campaign_items` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `pin_tuan_id` BIGINT COMMENT '拼团活动ID | 推断',
  `name` VARCHAR(256) COMMENT '名称 | PinTuanCampaignItem.name',
  `ticket_group` JSON COMMENT '票组（原 TicketGroup）| PinTuanCampaignItem.pinTuanCampaignItem',
  `ticket_category_id` BIGINT COMMENT '票档ID | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_ptitem_pt` (`pin_tuan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拼团票档项 | PinTuanCampaignItem / PinTuanCampaignMap';

CREATE TABLE IF NOT EXISTS `pin_tuan_orders` (
  `id` BIGINT NOT NULL COMMENT '拼团订单ID | 推断',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `order_id` BIGINT COMMENT '统一订单ID | 推断',
  `pin_tuan_id` BIGINT COMMENT '拼团活动ID | PinTuanOrderRequestBody.pinTuanId',
  `pin_tuan_campaign_item_id` BIGINT COMMENT '拼团项ID | PinTuanOrderRequestBody.pinTuanCampaignItemId',
  `count` INT COMMENT '数量 | PinTuanOrderRequestBody.count',
  `succeed_num` INT COMMENT '已成团人数 | 推断',
  `status` INT COMMENT '状态 | 推断',
  `add_time` BIGINT COMMENT '创建时间 | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_ptorder_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拼团订单 | v1/pinTuanOrder/make · confirmWithLogin · myOrders';

CREATE TABLE IF NOT EXISTS `group_buy_members` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `group_id` BIGINT COMMENT '拼团ID | 推断',
  `user_id` BIGINT COMMENT '用户ID | Flutter GroupBuyMember.userId',
  `nickname` VARCHAR(128) COMMENT '昵称 | Flutter',
  `avatar_url` VARCHAR(1024) COMMENT '头像 | Flutter',
  `is_leader` TINYINT COMMENT '是否团长 | Flutter',
  `joined_at` BIGINT COMMENT '加入时间 | Flutter GroupBuyMember.joinedAt',
  PRIMARY KEY (`id`),
  KEY `idx_gbm_group` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='拼团成员 | Flutter GroupBuyMember';

CREATE TABLE IF NOT EXISTS `proxy_buy_configs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `activity_id` BIGINT COMMENT '演出ID | 推断',
  `ticket_category_id` BIGINT COMMENT '票档ID | 推断',
  `proxy_buy_fee` DECIMAL(12,2) COMMENT '代抢费 | ProxyBuyInfo.proxyBuyFee',
  `proxy_buy_rule_desc` TEXT COMMENT '代抢规则 | ProxyBuyInfo.proxyBuyRuleDesc',
  `compensation_open` TINYINT COMMENT '无票赔付开关 | ProxyBuyCompensationInfo.open',
  `end_value` INT COMMENT '截止时间档位值 | ProxyBuyTimeInfo.endValue',
  `end_value_desc` VARCHAR(256) COMMENT '截止时间文案 | ProxyBuyTimeInfo.endValueDesc',
  `time_str` VARCHAR(128) COMMENT '轮次时间 | ProxyBuyTurnInfo.timeStr',
  `turn_title` VARCHAR(256) COMMENT '轮次标题 | ProxyBuyTurnInfo.title',
  `proxy_buy_time_info` JSON COMMENT '时间档位列表（原 List<ProxyBuyTimeInfo>）| ProxyBuyInfo.proxyBuyTimeInfo',
  `proxy_buy_turn_info` JSON COMMENT '轮次（原 ProxyBuyTurnInfo）| ProxyBuyInfo.proxyBuyTurnInfo',
  PRIMARY KEY (`id`),
  KEY `idx_proxycfg_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代抢配置 | ProxyBuyInfo / ProxyBuyCompensationInfo / ProxyBuyTimeInfo / ProxyBuyTurnInfo';

CREATE TABLE IF NOT EXISTS `proxy_buy_orders` (
  `id` BIGINT NOT NULL COMMENT '代抢单ID | Flutter ProxyBuyOrder.id',
  `order_number` VARCHAR(64) COMMENT '订单号 | Flutter ProxyBuySubmitState.orderNumber',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `show_title` VARCHAR(512) COMMENT '演出名 | Flutter',
  `show_poster` VARCHAR(1024) COMMENT '海报 | Flutter',
  `venue` VARCHAR(256) COMMENT '场馆 | Flutter',
  `event_time` VARCHAR(128) COMMENT '场次时间 | Flutter',
  `turn` JSON COMMENT '轮次（原 ProxyBuyTurn）| Flutter',
  `deadline` JSON COMMENT '截止档（原 ProxyBuyDeadline）| Flutter',
  `ticket_price` DECIMAL(12,2) COMMENT '票款 | Flutter',
  `quantity` INT COMMENT '数量 | Flutter',
  `proxy_buy_fee` DECIMAL(12,2) COMMENT '代抢费 | Flutter',
  `total_amount` DECIMAL(12,2) COMMENT '总额（= 票款×数量 + 代抢费）| Flutter ProxyBuyHelper.calculateTotalPrice',
  `status` VARCHAR(64) COMMENT '状态（pending / inProgress / success / failed / cancelled）| Flutter ProxyBuyStatus',
  `compensation_enabled` TINYINT COMMENT '是否赔付 | Flutter',
  `created_at` BIGINT COMMENT '创建时间 | Flutter',
  PRIMARY KEY (`id`),
  KEY `idx_proxyorder_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='代抢订单 | Flutter ProxyBuyOrder / ProxyBuySubmitState';

CREATE TABLE IF NOT EXISTS `transfers` (
  `id` BIGINT NOT NULL COMMENT '转票ID | TransformBean.transformId / TransformFeedBean.id',
  `user_id` BIGINT COMMENT '发布用户 | TransformFeedBean.userId',
  `activity_id` BIGINT COMMENT '演出ID | TransferTicket.activityId',
  `activity_event_id` BIGINT COMMENT '场次ID | TransferTicket.activityEventId',
  `ticket_category_id` BIGINT COMMENT '票档ID | TransferTicket.ticketCategoryId',
  `activity_name` VARCHAR(512) COMMENT '演出名 | TransformBean.activityName',
  `address` VARCHAR(1024) COMMENT '交易地点 | TransformBean.address',
  `category_desc` VARCHAR(256) COMMENT '票档描述 | TransformBean.categoryDesc',
  `event_specification` VARCHAR(256) COMMENT '场次规格 | TransformBean.eventSpecification',
  `count` INT COMMENT '数量 | TransferTicket.amount / TransformBean.count',
  `price` DECIMAL(12,2) COMMENT '价格 | TransferTicket.price / TransformBean.price',
  `content` TEXT COMMENT '说明 | TransferTicket.content / TransformFeedBean.content',
  `is_check` TINYINT COMMENT '是否已核验 | TransformBean.isCheck',
  `poster` VARCHAR(1024) COMMENT '海报 | TransformBean.poster / TransformFeedBean.poster',
  `liked` TINYINT COMMENT '已赞 | TransformFeedBean.liked',
  `likes` INT COMMENT '赞数 | TransformFeedBean.likes',
  `reply_count` INT COMMENT '回复数 | TransformFeedBean.replyCount',
  `status` INT COMMENT '状态（见 dict_enums.TransferStatus）| TransformFeedBean.status',
  `venue_city_id` INT COMMENT '场馆城市 | TransformFeedBean.venueCityId',
  `activity` JSON COMMENT '演出快照 | TransformFeedBean.activity',
  `activity_event` JSON COMMENT '场次快照 | TransformFeedBean.activityEvent',
  `ticket_category` JSON COMMENT '票档快照 | TransformFeedBean.ticketCategory',
  `user` JSON COMMENT '用户快照（原 UserBean）| TransformFeedBean.user',
  `add_time` BIGINT COMMENT '创建时间 | TransformFeedBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | TransformFeedBean.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_transfer_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='转票 / 求票 | TransferTicket / TransformBean / TransformFeedBean / TransferPagination';

CREATE TABLE IF NOT EXISTS `to_watch` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `activity_id` BIGINT COMMENT '演出ID | ToWatchBean.activityId',
  `activity_event_id` BIGINT COMMENT '场次ID | ToWatchBean.activityEventId',
  `activity_name` VARCHAR(512) COMMENT '演出名 | ToWatchBean.activityName',
  `short_name` VARCHAR(256) COMMENT '简称 | ToWatchBean.shortName',
  `activity_event_date` BIGINT COMMENT '场次日期 | ToWatchBean.activityEventDate',
  `order_id` BIGINT COMMENT '订单ID | ToWatchBean.orderId',
  `unified_order_id` BIGINT COMMENT '统一订单ID | ToWatchBean.unifiedOrderId',
  `venue` JSON COMMENT '场馆快照（原 Venue）| ToWatchBean.venue',
  `add_time` BIGINT COMMENT '想看时间 | 推断',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_towatch` (`user_id`,`activity_event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='想看 / 观演日历 | ToWatchBean（v1/user/toWatch）';

CREATE TABLE IF NOT EXISTS `favorites` (
  `id` BIGINT NOT NULL COMMENT '收藏ID | FavoriteFeedBean.id',
  `user_id` BIGINT COMMENT '用户ID | FavoriteFeedBean.userId',
  `activity_id` BIGINT COMMENT '演出ID | FavoriteFeedBean.activityId',
  `type` INT COMMENT '类型 | FavoriteFeedBean.type',
  `liked` TINYINT COMMENT '已赞 | FavoriteFeedBean.liked',
  `likes` INT COMMENT '赞数 | FavoriteFeedBean.likes',
  `reply_count` INT COMMENT '回复数 | FavoriteFeedBean.replyCount',
  `shares` INT COMMENT '分享数 | FavoriteFeedBean.shares',
  `notify_status` INT COMMENT '开售提醒状态 | FavoriteFeedBean.notifyStatus',
  `status` INT COMMENT '状态 | FavoriteFeedBean.status',
  `activity` JSON COMMENT '演出快照 | FavoriteFeedBean.activity',
  `user` JSON COMMENT '用户快照 | FavoriteFeedBean.user',
  `add_time` BIGINT COMMENT '创建时间 | FavoriteFeedBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | FavoriteFeedBean.updateTime',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fav` (`user_id`,`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏 / 想看动态 | FavoriteFeedBean（v1/activity/favorite/my）';
