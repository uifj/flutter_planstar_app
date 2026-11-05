-- ========================================================================
--  03 · 基础字典与演出商品
--  服务库: planstar_catalog
--  执行顺序: 01_init_databases.sql → 02 … 09 → 10 / 11 → 12_constraints.sql
--  本文件 23 张表: cities, country_areas, venues, activity_categories, activity_sub_tags, app_configs, app_versions, activities, activity_events, activity_details, activity_lineups, activity_galleries, activity_refund_policies, activity_refund_rules, activity_refund_rule_details, activity_refund_relations, activity_campaigns, activity_subjects, actors, actor_qr_codes, tours, shops, organizers
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/tree/main/sql
--    NN_<域>.sql 按服务分库 + migrations/<库>/000001_init.up.sql / .down.sql
--  方言: MySQL 8.0 / InnoDB / utf8mb4（按用户选择保持，未切换 PostgreSQL）
--  第三方 SDK 表（小米推送 / 极光 JPush / 百度定位·mshield / Bugly /
--    字节 AppLog·bdtracker）共 31 张已按要求全部移除。
-- ========================================================================

USE `planstar_catalog`;

-- ----------------------------------------------------------------------
--  域 2 · 基础字典与配置（dictionary / config）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `cities` (
  `city_id` INT NOT NULL COMMENT '城市ID | CityBean.cityId',
  `city_name` VARCHAR(128) COMMENT '城市名 | CityBean.cityName',
  `city_en_name` VARCHAR(128) COMMENT '英文名 | CityBean.cityEnName',
  `city_abbr_code` VARCHAR(32) COMMENT '缩写码 | CityBean.cityAbbrCode',
  `first_letter` VARCHAR(8) COMMENT '首字母 | CityBean.firstLetter',
  `hot_city` TINYINT(1) COMMENT '是否热门城市 | CityBean.hotCity',
  `province_id` INT COMMENT '省份ID | CityBean.provinceId',
  `region_city_id` INT COMMENT '区域城市ID | CityBean.regionCityId',
  `status` INT COMMENT '状态 | CityBean.status',
  `g_lat` DOUBLE COMMENT '纬度 | CityBean.GLat',
  `g_lng` DOUBLE COMMENT '经度 | CityBean.GLng',
  PRIMARY KEY (`city_id`),
  KEY `idx_city_hot` (`hot_city`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='城市 | CityBean（v1/cities · v2/cities/active · v1/cities/hot）';

CREATE TABLE IF NOT EXISTS `country_areas` (
  `country_area_id` INT NOT NULL COMMENT 'ID | CountryArea.countryAreaId',
  `country_area_name` VARCHAR(128) COMMENT '名称 | CountryArea.countryAreaName',
  `country_area_en_name` VARCHAR(128) COMMENT '英文名 | CountryArea.countryAreaEnName',
  `country_area_code` VARCHAR(32) COMMENT '编码 | CountryArea.countryAreaCode',
  `country_area_pin_yin` VARCHAR(128) COMMENT '拼音 | CountryArea.countryAreaPinYin',
  `country_level` INT COMMENT '层级 | CountryArea.countryLevel',
  `is_common` INT COMMENT '是否常用 | CountryArea.isCommon',
  PRIMARY KEY (`country_area_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='国家/地区 | CountryArea（v1/countryArea/list）';

CREATE TABLE IF NOT EXISTS `venues` (
  `venue_id` BIGINT NOT NULL COMMENT '场馆ID | Venue.id',
  `name` VARCHAR(256) COMMENT '场馆名 | Venue.name',
  `address` VARCHAR(1024) COMMENT '地址 | Venue.address',
  `avatar` VARCHAR(512) COMMENT '头像图 | Venue.avatar',
  `city_id` INT COMMENT '城市ID | Venue.cityId',
  `region_id` INT COMMENT '区域ID | Venue.regionId',
  `latitude` DOUBLE COMMENT '纬度 | Venue.latitude',
  `longitude` DOUBLE COMMENT '经度 | Venue.longitude',
  `parking` TEXT COMMENT '停车信息 | Venue.parking',
  `phones` VARCHAR(512) COMMENT '联系电话 | Venue.phones',
  `transportation` TEXT COMMENT '交通信息 | Venue.transportation',
  `show_count` INT COMMENT '演出数 | Flutter VenueSummary.showCount',
  `show_ids` JSON COMMENT '关联演出ID列表 | Flutter VenueSummary.showIds',
  `add_time` BIGINT COMMENT '创建时间 | Venue.addTime',
  `update_time` BIGINT COMMENT '更新时间 | Venue.updateTime',
  PRIMARY KEY (`venue_id`),
  KEY `idx_venue_city` (`city_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='场馆 | Venue + Flutter VenueSummary（v1/venues/{id}）';

CREATE TABLE IF NOT EXISTS `activity_categories` (
  `id` INT NOT NULL COMMENT '分类ID | ShowCategory.id',
  `name` VARCHAR(128) COMMENT '分类名 | ShowCategory.name',
  `en_name` VARCHAR(128) COMMENT '英文名 | ShowCategory.enName',
  `pinyin` VARCHAR(128) COMMENT '拼音 | ShowCategory.pinyin',
  `status` INT COMMENT '状态（1 上架）| ShowCategory.status',
  `is_select` TINYINT(1) COMMENT '是否选中 | PnConfig.OptionsBean.isSelect',
  `type` VARCHAR(64) COMMENT '类型 | PnConfig.type',
  `value` VARCHAR(256) COMMENT '值 | PnConfig.value',
  `dacu` VARCHAR(256) COMMENT '大促标记 | PnConfig.dacu',
  `add_time` BIGINT COMMENT '创建时间 | PnConfig.addTime',
  `update_time` BIGINT COMMENT '更新时间 | PnConfig.updateTime',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出一级分类 | ShowCategory / PnConfig.CategoriesBean（v2/config/categories）';

CREATE TABLE IF NOT EXISTS `activity_sub_tags` (
  `id` INT NOT NULL COMMENT '标签ID | SubCategoryTag.id',
  `category_id` INT COMMENT '一级分类ID | SubCategoryTag.categoryId',
  `name` VARCHAR(128) COMMENT '标签名 | SubCategoryTag.name',
  `sub_category_id` VARCHAR(64) COMMENT '子分类ID | PnConfig.subCategoryId',
  `status` INT COMMENT '状态 | PnConfig.status',
  `add_time` BIGINT COMMENT '创建时间 | PnConfig.addTime',
  `update_time` BIGINT COMMENT '更新时间 | PnConfig.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_subtag_cat` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出二级标签 | SubCategoryTag / SubCategoryTagsBean';

CREATE TABLE IF NOT EXISTS `app_configs` (
  `id` BIGINT NOT NULL COMMENT '配置ID | PnConfig.id',
  `balance_pay` TINYINT(1) COMMENT '是否支持余额支付 | PnConfig.balancePay',
  `contact_phone` VARCHAR(64) COMMENT '客服电话 | PnConfig.contactPhone',
  `express_name` VARCHAR(128) COMMENT '快递名称 | PnConfig.expressName',
  `express_phone` VARCHAR(64) COMMENT '快递电话 | PnConfig.expressPhone',
  `express_address` VARCHAR(512) COMMENT '快递地址 | PnConfig.expressAddress',
  `self_get_address` VARCHAR(512) COMMENT '自取地址 | PnConfig.selfGetAddress',
  `self_get_time` VARCHAR(128) COMMENT '自取时间 | PnConfig.selfGetTime',
  `img_domain` VARCHAR(256) COMMENT '图片域名 | PnConfig.imgDomain',
  `img_ssl_domain` VARCHAR(256) COMMENT '图片 HTTPS 域名 | PnConfig.imgSslDomain',
  `is_time_to_dacu` TINYINT(1) COMMENT '是否大促期 | PnConfig.isTimeToDacu',
  `sms_captcha_on` TINYINT(1) COMMENT '是否开启短信验证码 | PnConfig.smsCaptchaOn',
  `ticket_enough_count` INT COMMENT '票量充足阈值 | PnConfig.ticketEnoughCount',
  `launch_screen` VARCHAR(1024) COMMENT '启动屏 | PnConfig.launchScreen',
  `payment_types` JSON COMMENT '支付方式列表 | PnConfig.paymentTypes',
  `receive_types` JSON COMMENT '收货方式列表 | PnConfig.receiveTypes',
  `payment_tips` JSON COMMENT '支付提示 | PnConfig.paymentTips',
  `activity_icons` JSON COMMENT '活动图标 | PnConfig.activityIcons',
  `search_navigation_v2` JSON COMMENT '搜索导航配置 | PnConfig.searchNavigationV2',
  `categories` JSON COMMENT '分类配置 | PnConfig.categories',
  `sub_category_tags` JSON COMMENT '二级标签 | PnConfig.subCategoryTags',
  `options` JSON COMMENT '选项列表 | PnConfig.options',
  `add_time` BIGINT COMMENT '创建时间 | PnConfig.addTime',
  `update_time` BIGINT COMMENT '更新时间 | PnConfig.updateTime',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全局配置 | PnConfig（v2/config · v3/config）';

CREATE TABLE IF NOT EXISTS `app_versions` (
  `version_code` INT NOT NULL COMMENT '版本号 | UpdateInfo.versionCode',
  `version_name` VARCHAR(64) COMMENT '版本名 | UpdateInfo.versionName',
  `changelog` TEXT COMMENT '更新日志 | UpdateInfo.changelog',
  `install_url` VARCHAR(1024) COMMENT '安装地址 | UpdateInfo.installUrl',
  `is_force_update` TINYINT(1) COMMENT '是否强制更新 | UpdateInfo.isForceUpdate',
  `is_ignorable` TINYINT(1) COMMENT '是否可忽略 | UpdateInfo.isIgnorable',
  `tips_interval_days` INT COMMENT '提示间隔天数 | UpdateInfo.tipsIntervalDays',
  `type` VARCHAR(64) COMMENT '类型 | UpdateInfo.type',
  PRIMARY KEY (`version_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='版本更新 | UpdateInfo（GET apps/latest/{id} · v2/apkTool/latest）';

-- ----------------------------------------------------------------------
--  域 3 · 演出商品（show / goods）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `activities` (
  `id` BIGINT NOT NULL COMMENT '演出ID | ActivityBean.id（注意：activityId 是另一个独立字段，服务端有时只填一个）',
  `activity_id` BIGINT COMMENT '演出ID（冗余/别名）| ActivityBean.activityId',
  `name` VARCHAR(512) COMMENT '演出名 | ActivityBean.name',
  `shortname` VARCHAR(256) COMMENT '简称 | ActivityBean.shortname',
  `activity_shortname` VARCHAR(256) COMMENT '简称（冗余）| ActivityBean.activityShortname',
  `sub_category_name` VARCHAR(128) COMMENT '二级分类名 | ActivityBean.subCategoryName',
  `category_id` INT COMMENT '分类ID | ActivityBean.categoryId',
  `category_name` VARCHAR(128) COMMENT '分类名 | ActivityBean.categoryName',
  `category_hot_rank` VARCHAR(128) COMMENT '分类热度排名 | ActivityBean.categoryHotRank',
  `activity_type` INT COMMENT '演出类型 | ActivityBean.activityType',
  `show_type` INT COMMENT '演出形态 | ActivityBean.showType',
  `link_type` VARCHAR(64) COMMENT '链接类型 | ActivityBean.linkType',
  `type` INT COMMENT '类型 | ActivityBean.type',
  `type_desc` VARCHAR(256) COMMENT '类型描述 | ActivityBean.typeDesc',
  `actor_id` BIGINT COMMENT '艺人ID | ActivityBean.actorId',
  `venue_id` BIGINT COMMENT '场馆ID | ActivityBean.venueId',
  `venue_name` VARCHAR(256) COMMENT '场馆名 | ActivityBean.venueName',
  `venue_city_id` INT COMMENT '场馆城市ID | ActivityBean.venueCityId',
  `city_id` INT COMMENT '城市ID | ActivityBean.cityId',
  `city_name` VARCHAR(128) COMMENT '城市名 | ActivityBean.cityName',
  `shop_id` BIGINT COMMENT '店铺ID | ActivityBean.shopId',
  `desc` TEXT COMMENT '描述 | ActivityBean.desc',
  `poster` VARCHAR(1024) COMMENT '海报 | ActivityBean.poster',
  `img` VARCHAR(1024) COMMENT '图片 | ActivityBean.img',
  `promo_img` VARCHAR(1024) COMMENT '推广图 | ActivityBean.promoImg',
  `tag_image` VARCHAR(1024) COMMENT '角标图 | ActivityBean.tagImage',
  `area_image` VARCHAR(1024) COMMENT '区域图 | ActivityBean.areaImage',
  `icon` VARCHAR(1024) COMMENT '图标 | ActivityBean.icon',
  `video` VARCHAR(1024) COMMENT '视频 | ActivityBean.video',
  `start` BIGINT COMMENT '开始时间（epoch 毫秒）| ActivityBean.start',
  `end` BIGINT COMMENT '结束时间（epoch 毫秒）| ActivityBean.end',
  `open_time` BIGINT COMMENT '开售时间 | ActivityBean.openTime',
  `start_sell_time` BIGINT COMMENT '开卖时间 | ActivityBean.startSellTime',
  `time_range` VARCHAR(256) COMMENT '时间文案 | ActivityBean.timeRange',
  `duration` VARCHAR(128) COMMENT '时长 | ActivityBean.duration',
  `year` VARCHAR(16) COMMENT '年份 | ActivityBean.year',
  `distance` VARCHAR(64) COMMENT '距离 | ActivityBean.distance',
  `low_price` DECIMAL(12,2) COMMENT '最低价 | ActivityBean.lowPrice',
  `high_price` DECIMAL(12,2) COMMENT '最高价 | ActivityBean.highPrice',
  `discount_amount` DECIMAL(12,2) COMMENT '优惠金额 | ActivityBean.discountAmount',
  `discount_rate` DECIMAL(10,4) COMMENT '折扣率 | ActivityBean.discountRate',
  `privilege_discount_amount` DECIMAL(12,2) COMMENT '会员优惠金额 | ActivityBean.privilegeDiscountAmount',
  `rank` DOUBLE COMMENT '排序权重 | ActivityBean.rank',
  `star` INT COMMENT '星级 | ActivityBean.star',
  `review_num` INT COMMENT '评论数 | ActivityBean.reviewNum',
  `want_watch_num` INT COMMENT '想看数 | ActivityBean.wantWatchNum',
  `total_order_count` INT COMMENT '总订单数 | ActivityBean.totalOrderCount',
  `activity_event_num` INT COMMENT '场次数 | ActivityBean.activityEventNum',
  `activity_num` INT COMMENT '活动数 | ActivityBean.activityNum',
  `favor_type` INT COMMENT '收藏类型 | ActivityBean.favorType',
  `status` INT COMMENT '状态 | ActivityBean.status',
  `publish_status` INT COMMENT '发布状态 | ActivityBean.publishStatus',
  `searchable` INT COMMENT '是否可搜索 | ActivityBean.searchable',
  `sold_out` TINYINT(1) COMMENT '是否售罄 | ActivityBean.soldOut',
  `normal_sold_out` TINYINT(1) COMMENT '普通票售罄 | ActivityBean.normalSoldOut',
  `has_seat` TINYINT(1) COMMENT '是否有座 | ActivityBean.hasSeat',
  `area_ticket_type` INT COMMENT '区域票类型 | ActivityBean.areaTicketType',
  `activity_seat_map_opened` TINYINT(1) COMMENT '选座图是否开放 | ActivityBean.activitySeatMapOpened',
  `b2c_opened` TINYINT(1) COMMENT 'B2C 是否开放 | ActivityBean.b2cOpened',
  `credit_pay` TINYINT(1) COMMENT '是否支持信用付 | ActivityBean.creditPay',
  `can_buy_ecard` TINYINT(1) COMMENT '是否可买电子卡 | ActivityBean.canBuyEcard',
  `can_review` TINYINT(1) COMMENT '是否可评论 | ActivityBean.canReview',
  `direct_buy_official` TINYINT(1) COMMENT '官方直购 | ActivityBean.directBuyOfficial',
  `seat_buy_official` TINYINT(1) COMMENT '官方选座 | ActivityBean.seatBuyOfficial',
  `general_agency` TINYINT(1) COMMENT '总代 | ActivityBean.generalAgency',
  `proxy_buy` TINYINT(1) COMMENT '支持代抢 | ActivityBean.proxyBuy',
  `only_proxy_buy` TINYINT(1) COMMENT '仅代抢 | ActivityBean.onlyProxyBuy',
  `support_direct_buy` TINYINT(1) COMMENT '支持直购 | ActivityBean.supportDirectBuy',
  `support_proxy_buy` TINYINT(1) COMMENT '支持代抢 | ActivityBean.supportProxyBuy',
  `group_buy` TINYINT(1) COMMENT '支持拼团 | ActivityBean.groupBuy',
  `ultra_low_group` TINYINT(1) COMMENT '超低价拼团 | ActivityBean.ultraLowGroup',
  `is_best_discount` TINYINT(1) COMMENT '最优折扣 | ActivityBean.isBestDiscount',
  `need_speed_pack_buy` TINYINT(1) COMMENT '需加速包 | ActivityBean.needSpeedPackBuy',
  `no_ticket_compensate_switch` TINYINT(1) COMMENT '无票赔付开关 | ActivityBean.noTicketCompensateSwitch',
  `non_refundable_exchangeable` TINYINT(1) COMMENT '不可退可换 | ActivityBean.nonRefundableExchangeable',
  `discontinued_ticket_notice` TINYINT(1) COMMENT '停售通知 | ActivityBean.discontinuedTicketNotice',
  `pay_after_use_switch` TINYINT(1) COMMENT '先用后付开关 | ActivityBean.payAfterUseSwitch',
  `service_charge_open` TINYINT(1) COMMENT '服务费开关 | ActivityBean.serviceChargeOpen',
  `show_start_remind` TINYINT(1) COMMENT '开演提醒 | ActivityBean.showStartRemind',
  `speed_express` TINYINT(1) COMMENT '极速配送 | ActivityBean.speedExpress',
  `wuyou_transfer_supported` TINYINT(1) COMMENT '无忧转票 | ActivityBean.wuyouTransferSupported',
  `price_guarantee_type` INT COMMENT '保价类型 | ActivityBean.priceGuaranteeType',
  `postage_tip` VARCHAR(512) COMMENT '运费提示 | ActivityBean.postageTip',
  `pre_sale_tip` VARCHAR(512) COMMENT '预售提示 | ActivityBean.preSaleTip',
  `schema` VARCHAR(1024) COMMENT '跳转 scheme | ActivityBean.schema',
  `num_max` INT COMMENT '单笔最大购买数 | ActivityBean.numMax',
  `num_min` INT COMMENT '单笔最小购买数 | ActivityBean.numMin',
  `order_limit` INT COMMENT '限购 | ActivityBean.orderLimit',
  `tour_name` VARCHAR(256) COMMENT '巡演名 | ActivityBean.tourName',
  `venue` JSON COMMENT '场馆快照（原 Venue）| ActivityBean.venue',
  `actors` JSON COMMENT '艺人列表（原 List<ActorBean>）| ActivityBean.actors',
  `actor_info` JSON COMMENT '艺人二维码（原 ActorQrBean）| ActivityBean.actorInfo',
  `activity_details` JSON COMMENT '详情列表（原 List<ActivityDetail>）| ActivityBean.activityDetails',
  `activity_lineup` JSON COMMENT '阵容（原 List<ActivityLineupBean>）| ActivityBean.activityLineup',
  `activity_linked_groups` JSON COMMENT '关联群组（原 List<ActivityGroupBean>）| ActivityBean.activityLinkedGroups',
  `activity_purchase_info` JSON COMMENT '购买信息（内部类）| ActivityBean.activityPurchaseInfo',
  `activity_refund_policy` JSON COMMENT '退票政策（原 ActivityRefundPolicyBean）| ActivityBean.activityRefundPolicy',
  `campaigns` JSON COMMENT '活动列表（原 List<ActivityCampaign>）| ActivityBean.campaigns',
  `choose_ticket_calendar_data` JSON COMMENT '选票日历（原 ChooseTicketCalendarData）| ActivityBean.chooseTicketCalendarData',
  `display_tags` JSON COMMENT '展示标签（内部类 ActivityDisplayTag）| ActivityBean.displayTags',
  `enter_tip` JSON COMMENT '入场提示（原 ShowTip）| ActivityBean.enterTip',
  `events` JSON COMMENT '场次列表（原 List<ActivityEventBean>）| ActivityBean.events',
  `has_ticket_events` JSON COMMENT '有票场次 | ActivityBean.hasTicketEvents',
  `order_num_limit` JSON COMMENT '限购（内部类 OrderNumLimitBean）| ActivityBean.orderNumLimit',
  `pin_tuan_info` JSON COMMENT '拼团信息（原 PinTuanInfo）| ActivityBean.pinTuanInfo',
  `proxy_buy_info` JSON COMMENT '代抢信息（原 ProxyBuyInfo）| ActivityBean.proxyBuyInfo',
  `ticket_categories` JSON COMMENT '票档（原 List<TicketCategory>）| ActivityBean.ticketCategories',
  `ticket_tip` JSON COMMENT '购票提示（原 ShowTip）| ActivityBean.ticketTip',
  `tour` JSON COMMENT '巡演（内部类 TourBean）| ActivityBean.tour',
  `activities` JSON COMMENT '关联演出（原 List<ActivityBean>）| ActivityBean.activities',
  `add_time` BIGINT COMMENT '创建时间 | ActivityBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | ActivityBean.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_act_city` (`city_id`),
  KEY `idx_act_cat` (`category_id`),
  KEY `idx_act_venue` (`venue_id`),
  KEY `idx_act_status` (`status`,`publish_status`),
  KEY `idx_act_start` (`start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出主档 | ActivityBean（100+ 顶层字段，含 4 个内部类；DTO 字段全量落列）';

CREATE TABLE IF NOT EXISTS `activity_events` (
  `id` BIGINT NOT NULL COMMENT '场次ID | ActivityEventBean.id',
  `activity_id` BIGINT COMMENT '演出ID | ActivityEventBean.activityId',
  `start` BIGINT COMMENT '开演时间 | ActivityEventBean.start',
  `end` BIGINT COMMENT '结束时间 | ActivityEventBean.end',
  `time_range` VARCHAR(256) COMMENT '时间文案 | Test.timeRange',
  `specification` VARCHAR(256) COMMENT '规格 | ActivityEventBean.specification',
  `desc` TEXT COMMENT '描述 | ActivityEventBean.desc',
  `low_price` DECIMAL(12,2) COMMENT '最低价 | ActivityEventBean.lowPrice',
  `discount_amount` DECIMAL(12,2) COMMENT '优惠金额 | ActivityEventBean.discountAmount',
  `discount_rate` DECIMAL(10,4) COMMENT '折扣率 | ActivityEventBean.discountRate',
  `discount_flag` TINYINT(1) COMMENT '是否有折扣 | ActivityEventBean.discountFlag',
  `price_lowest` TINYINT(1) COMMENT '是否最低价 | ActivityEventBean.priceLowest',
  `has_ticket` TINYINT(1) COMMENT '是否有票 | ActivityEventBean.hasTicket',
  `tickets_number` INT COMMENT '票数量 | ActivityEventBean.ticketsNumber',
  `tickets_flag` INT COMMENT '票标记 | ActivityEventBean.ticketsFlag',
  `seat_map_flag` TINYINT(1) COMMENT '是否选座图 | ActivityEventBean.seatMapFlag',
  `seat_tickets_size` INT COMMENT '座位票数 | ActivityEventBean.seatTicketsSize',
  `ticket_group_id` INT COMMENT '票组ID | ActivityEventBean.ticketGroupId',
  `status` INT COMMENT '状态（2=停售，见 dict_enums.SaleStatus）| ActivityEventBean.status',
  `venue_id` BIGINT COMMENT '场馆ID（Test 补充）| Test.venueId',
  `venue_name` VARCHAR(256) COMMENT '场馆名（Test 补充）| Test.venueName',
  `available_numbers` JSON COMMENT '可选数量（原 List<Integer>）| ActivityEventBean.availableNumbers',
  `ticket_categories` JSON COMMENT '票档列表（原 List<? extends TicketCategory>）| ActivityEventBean.ticketCategories',
  `add_time` BIGINT COMMENT '创建时间 | ActivityEventBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | ActivityEventBean.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_event_act` (`activity_id`),
  KEY `idx_event_start` (`start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出场次 | ActivityEventBean（v5/activities/getAllEvents · v1/activities/{id}/events）';

CREATE TABLE IF NOT EXISTS `activity_details` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivityDetail.id',
  `activity_id` BIGINT COMMENT '演出ID | ActivityDetail.activityId',
  `detail_desc` TEXT COMMENT '详情内容 | ActivityDetail.detailDesc',
  `type` INT COMMENT '详情类型 | ActivityDetail.type',
  `add_time` BIGINT COMMENT '创建时间 | ActivityDetail.addTime',
  `update_time` BIGINT COMMENT '更新时间 | ActivityDetail.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_adetail_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出详情分段 | ActivityDetail（type 见 dict_enums.ActivityDetailType）';

CREATE TABLE IF NOT EXISTS `activity_lineups` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivityLineupBean.id',
  `activity_id` BIGINT COMMENT '演出ID | 推断',
  `name` VARCHAR(256) COMMENT '姓名 | ActivityLineupBean.name',
  `role` VARCHAR(128) COMMENT '角色 | ActivityLineupBean.role',
  `avatar` VARCHAR(1024) COMMENT '头像 | ActivityLineupBean.avatar',
  `actor_detail_schema` VARCHAR(1024) COMMENT '艺人详情 scheme | ActivityLineupBean.actorDetailSchema',
  `follow_num` INT COMMENT '关注数 | ActivityLineupBean.followNum',
  `followed` TINYINT(1) COMMENT '是否已关注 | ActivityLineupBean.followed',
  `fans` JSON COMMENT '粉丝列表（原 List<UserBean>）| ActivityLineupBean.fans',
  PRIMARY KEY (`id`),
  KEY `idx_lineup_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出阵容 | ActivityLineupBean / ActorBean';

CREATE TABLE IF NOT EXISTS `activity_galleries` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivityGalleryBean.id',
  `activity_id` BIGINT COMMENT '演出ID | ActivityGalleryBean.activityId',
  `content` TEXT COMMENT '内容 | ActivityGalleryBean.content',
  `poster` VARCHAR(1024) COMMENT '图片 | ActivityGalleryBean.poster',
  `url` VARCHAR(1024) COMMENT '链接 | ActivityGalleryBean.url',
  `type` INT COMMENT '类型 | ActivityGalleryBean.type',
  `feed_type` VARCHAR(64) COMMENT '流类型 | ActivityGalleryBean.feedType',
  `subject_id` BIGINT COMMENT '主体ID | ActivityGalleryBean.subjectId',
  `subject_type` INT COMMENT '主体类型 | ActivityGalleryBean.subjectType',
  `review_id` BIGINT COMMENT '评论ID | ActivityGalleryBean.reviewId',
  `liked` TINYINT(1) COMMENT '已赞 | ActivityGalleryBean.liked',
  `likes` INT COMMENT '赞数 | ActivityGalleryBean.likes',
  `reply_count` INT COMMENT '回复数 | ActivityGalleryBean.replyCount',
  `status` INT COMMENT '状态 | ActivityGalleryBean.status',
  `user` JSON COMMENT '用户快照（原 UserBean）| ActivityGalleryBean.user',
  `add_time` BIGINT COMMENT '创建时间 | ActivityGalleryBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | ActivityGalleryBean.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_gallery_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出图库 / 买家秀 | ActivityGalleryBean（v1/activityGallery/{activityId}）';

CREATE TABLE IF NOT EXISTS `activity_refund_policies` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivityRefundPolicyBean.id',
  `activity_id` BIGINT COMMENT '演出ID | ActivityRefundPolicyBean.activityId',
  `content` TEXT COMMENT '政策正文 | ActivityRefundPolicyBean.content',
  `tips` TEXT COMMENT '提示 | ActivityRefundPolicyBean.tips',
  `refund_rule_list` JSON COMMENT '规则列表（原 List<ActivityRefundRuleBean>）| ActivityRefundPolicyBean.refundRuleList',
  PRIMARY KEY (`id`),
  KEY `idx_refpolicy_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退票政策 | ActivityRefundPolicyBean / ShowTips';

CREATE TABLE IF NOT EXISTS `activity_refund_rules` (
  `id` BIGINT NOT NULL COMMENT '规则ID | ActivityRefundRuleBean.id',
  `activity_id` BIGINT COMMENT '演出ID | 推断',
  `relations` JSON COMMENT '关联对象（原 List<ActivityRefundRelationBean>）| ActivityRefundRuleBean.relations',
  `rule_details` JSON COMMENT '规则明细（原 List<ActivityRefundRuleDetailBean>）| ActivityRefundRuleBean.ruleDetails',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退票规则 | ActivityRefundRuleBean';

CREATE TABLE IF NOT EXISTS `activity_refund_rule_details` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivityRefundRuleDetailBean.id',
  `rule_id` BIGINT COMMENT '规则ID | 推断',
  `start_time` BIGINT COMMENT '起始时间 | ActivityRefundRuleDetailBean.startTime',
  `end_time` BIGINT COMMENT '结束时间 | ActivityRefundRuleDetailBean.endTime',
  `refund_amount` VARCHAR(128) COMMENT '退款金额/比例 | ActivityRefundRuleDetailBean.refundAmount',
  `refund_mode` VARCHAR(64) COMMENT '退款模式 | ActivityRefundRuleDetailBean.refundMode',
  PRIMARY KEY (`id`),
  KEY `idx_refdetail_rule` (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退票规则明细 | ActivityRefundRuleDetailBean（refundMode 见 dict_enums.RefundRuleMode）';

CREATE TABLE IF NOT EXISTS `activity_refund_relations` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivityRefundRelationBean.id',
  `biz_id` BIGINT COMMENT '业务ID | ActivityRefundRelationBean.bizId',
  `biz_type` VARCHAR(64) COMMENT '业务类型 | ActivityRefundRelationBean.bizType',
  `name` VARCHAR(256) COMMENT '名称 | ActivityRefundRelationBean.name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退票规则关联对象 | ActivityRefundRelationBean（bizType 见 RefundRelationBizType）';

CREATE TABLE IF NOT EXISTS `activity_campaigns` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivityCampaign.id',
  `activity_id` BIGINT COMMENT '演出ID | 推断',
  `name` VARCHAR(256) COMMENT '活动名 | ActivityCampaign.name',
  `desc` TEXT COMMENT '描述 | ActivityCampaign.desc',
  `campaign_rule` TEXT COMMENT '规则 | ActivityCampaign.campaignRule',
  `head_img` VARCHAR(1024) COMMENT '头图 | ActivityCampaign.headImg',
  `share_title` VARCHAR(256) COMMENT '分享标题 | ActivityCampaign.shareTitle',
  `share_desc` VARCHAR(1024) COMMENT '分享描述 | ActivityCampaign.shareDesc',
  `share_img` VARCHAR(1024) COMMENT '分享图 | ActivityCampaign.shareImg',
  `purchase_type` INT COMMENT '购买类型 | ActivityCampaign.purchaseType',
  `status` INT COMMENT '状态 | ActivityCampaign.status',
  `type` INT COMMENT '类型 | ActivityCampaign.type',
  `url` VARCHAR(1024) COMMENT '链接 | ActivityCampaign.url',
  `user_group_id` INT COMMENT '用户群ID | ActivityCampaign.userGroupId',
  `user_group_type` INT COMMENT '用户群类型 | ActivityCampaign.userGroupType',
  `add_time` BIGINT COMMENT '创建时间 | ActivityCampaign.addTime',
  `update_time` BIGINT COMMENT '更新时间 | ActivityCampaign.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_actcamp_act` (`activity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出营销活动 | ActivityCampaign';

CREATE TABLE IF NOT EXISTS `activity_subjects` (
  `id` BIGINT NOT NULL COMMENT 'ID | ActivitySubjectBean.id',
  `title` VARCHAR(512) COMMENT '标题 | ActivitySubjectBean.title',
  `desc` TEXT COMMENT '描述 | ActivitySubjectBean.desc',
  `head_img` VARCHAR(1024) COMMENT '头图 | ActivitySubjectBean.headImg',
  `img` VARCHAR(1024) COMMENT '图片 | ActivitySubjectBean.img',
  `share_title` VARCHAR(256) COMMENT '分享标题 | ActivitySubjectBean.shareTitle',
  `share_desc` VARCHAR(1024) COMMENT '分享描述 | ActivitySubjectBean.shareDesc',
  `share_img` VARCHAR(1024) COMMENT '分享图 | ActivitySubjectBean.shareImg',
  `low_price` DECIMAL(12,2) COMMENT '最低价 | ActivitySubjectBean.lowPrice',
  `sold_out` TINYINT(1) COMMENT '售罄 | ActivitySubjectBean.soldOut',
  `sort` INT COMMENT '排序 | ActivitySubjectBean.sort',
  `type` INT COMMENT '类型 | ActivitySubjectBean.type',
  `activity` JSON COMMENT '演出快照（原 ActivityBean）| ActivitySubjectBean.activity',
  `venue` JSON COMMENT '场馆快照（原 Venue）| ActivitySubjectBean.venue',
  `reviews` JSON COMMENT '评论列表（原 List<Review>）| ActivitySubjectBean.reviews',
  `floors` JSON COMMENT '楼层（原 List<FloorsBean>）| ActivitySubjectBean.floors',
  `contents` JSON COMMENT '内容（原 List<ContentsBean>）| ActivitySubjectBean.contents',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='演出专题 | ActivitySubjectBean';

CREATE TABLE IF NOT EXISTS `actors` (
  `id` BIGINT NOT NULL COMMENT '艺人ID | ActorBean.id / StationBean.id',
  `user_id` BIGINT COMMENT '关联用户ID | ActorBean.userId',
  `name` VARCHAR(256) COMMENT '姓名 | ActorBean.name',
  `avatar` VARCHAR(1024) COMMENT '头像 | ActorBean.avatar',
  `background_image` VARCHAR(1024) COMMENT '背景图 | ActorBean.backgroundImage',
  `show_desc` TEXT COMMENT '简介 | ActorBean.showDesc',
  `actor_detail_schema` VARCHAR(1024) COMMENT '详情 scheme | ActorBean.actorDetailSchema',
  `ip_type` INT COMMENT 'IP 类型 | StationBean.ipType',
  `follow_num` INT COMMENT '关注数 | ActorBean.followNum',
  `followings` INT COMMENT '关注数（StationBean）| StationBean.followings',
  `followed` TINYINT(1) COMMENT '是否已关注 | StationBean.followed',
  `activity_count` INT COMMENT '演出数 | ActorBean.activityCount',
  `goods_count` INT COMMENT '商品数 | StationBean.goodsCount',
  `year` VARCHAR(16) COMMENT '年份 | StationBean.year',
  `status` VARCHAR(64) COMMENT '状态 | StationBean.status',
  `fans` JSON COMMENT '粉丝（原 List<UserBean>）| ActorBean.fans',
  `top_activities` JSON COMMENT '热门演出（原 List<ActivityBean>）| ActorBean.topActivities',
  `activities` JSON COMMENT '演出列表（原 List<Activity>）| StationBean.activities',
  `tours` JSON COMMENT '巡演（原 List<Tour>）| StationBean.tours',
  `posters` JSON COMMENT '海报（原 List<Poster>）| StationBean.posters',
  `head_posters` JSON COMMENT '头图（原 List<String>）| StationBean.headPosters',
  `related_activity_id_list` JSON COMMENT '关联演出（原 List<Long>）| StationBean.relatedActivityIdList',
  `activity_marketing_image_url` VARCHAR(1024) COMMENT '营销图 | StationBean.activityMarketingImageUrl',
  `activity_poster_icon` VARCHAR(1024) COMMENT '海报角标 | StationBean.activityPosterIcon',
  `add_time` BIGINT COMMENT '创建时间 | StationBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | StationBean.updateTime',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='艺人 / IP 站点 | ActorBean / StationBean / HotActorsBean / HomeActorsBean';

CREATE TABLE IF NOT EXISTS `actor_qr_codes` (
  `actor_id` VARCHAR(64) NOT NULL COMMENT '艺人ID | ActorQrBean.actorId',
  `pre_sales_qr` VARCHAR(1024) COMMENT '售前二维码 | ActorQrBean.preSalesQr',
  `after_sales_qr` VARCHAR(1024) COMMENT '售后二维码 | ActorQrBean.afterSalesQr',
  PRIMARY KEY (`actor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='艺人客服二维码 | ActorQrBean';

CREATE TABLE IF NOT EXISTS `tours` (
  `tour_id` BIGINT NOT NULL COMMENT '巡演ID | HotTourBean.tourId',
  `actor_id` BIGINT COMMENT '艺人ID | HotTourBean.actorId',
  `tour_intellectual_property_id` BIGINT COMMENT 'IP ID | HotTourBean.tourIntellectualPropertyId',
  `tour_title` VARCHAR(512) COMMENT '巡演标题 | HotTourBean.tourTitle',
  `tour_poster` VARCHAR(1024) COMMENT '巡演海报 | HotTourBean.tourPoster',
  `activity_id` BIGINT COMMENT '演出ID | StationBean.activityId',
  `activity_count` INT COMMENT '演出数 | HotTourBean.activityCount',
  `activity_in_tour_tag_type` VARCHAR(64) COMMENT '标签类型 | StationBean.activityInTourTagType',
  `city_id` INT COMMENT '城市ID | StationBean.cityId',
  `city_name` VARCHAR(128) COMMENT '城市名 | StationBean.cityName',
  `start_time` BIGINT COMMENT '开始时间 | StationBean.startTime',
  `end_time` BIGINT COMMENT '结束时间 | StationBean.endTime',
  `time_range` VARCHAR(256) COMMENT '时间文案 | StationBean.timeRange',
  `low_price` DECIMAL(12,2) COMMENT '最低价 | StationBean.lowPrice',
  `group_buy` TINYINT(1) COMMENT '拼团 | StationBean.groupBuy',
  `marketing_tag` VARCHAR(256) COMMENT '营销标签 | StationBean.marketingTag',
  `marketing_tag_type` INT COMMENT '标签类型 | StationBean.marketingTagType',
  `show_time_pending` TINYINT(1) COMMENT '时间待定 | StationBean.showTimePending',
  `show_time_pending_text` VARCHAR(256) COMMENT '待定文案 | StationBean.showTimePendingText',
  `type` VARCHAR(64) COMMENT '类型 | StationBean.type',
  `url` VARCHAR(1024) COMMENT '链接 | StationBean.url',
  PRIMARY KEY (`tour_id`),
  KEY `idx_tour_actor` (`actor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='巡演 / 站点演出 | TourBean / HotTourBean / StationBean 的 tour 部分';

CREATE TABLE IF NOT EXISTS `shops` (
  `shop_id` BIGINT NOT NULL COMMENT '店铺ID | Shop.id',
  `name` VARCHAR(256) COMMENT '店铺名 | Shop.name',
  `img` VARCHAR(1024) COMMENT '店铺图 | Shop.img',
  `mobile` VARCHAR(64) COMMENT '联系电话 | Shop.mobile',
  `owner` BIGINT COMMENT '店主 | Shop.owner',
  `city_id` INT COMMENT '城市ID | Shop.cityId',
  `auto_approve` INT COMMENT '自动审核 | Shop.autoApprove',
  `status` INT COMMENT '状态 | Shop.status',
  `type` INT COMMENT '类型 | Shop.type',
  `total_score` INT COMMENT '总分 | Shop.totalScore',
  `shop_name` VARCHAR(256) COMMENT '店铺名（ShopInfo 冗余）| ShopInfo.shopName',
  `shop_lisence_url` VARCHAR(1024) COMMENT '营业执照 | ShopInfo.shopLisenceUrl',
  `verified` TINYINT(1) COMMENT '是否认证 | ShopInfo.verified',
  `activity_event_num` INT COMMENT '场次数 | SearchResultShopBean.activityEventNum',
  `activity_num` INT COMMENT '演出数 | SearchResultShopBean.activityNum',
  `activity_type` INT COMMENT '演出类型 | SearchResultShopBean.activityType',
  `promo_img` VARCHAR(1024) COMMENT '推广图 | SearchResultShopBean.promoImg',
  `add_time` BIGINT COMMENT '创建时间 | Shop.addTime',
  `update_time` BIGINT COMMENT '更新时间 | Shop.updateTime',
  PRIMARY KEY (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺 / 卖家 | Shop / ShopInfo / SearchResultShopBean';

CREATE TABLE IF NOT EXISTS `organizers` (
  `shop_id` BIGINT NOT NULL COMMENT '机构ID | OrganizerBean.shopId',
  `name` VARCHAR(256) COMMENT '名称 | OrganizerBean.name',
  `head_img` VARCHAR(1024) COMMENT '头图 | OrganizerBean.headImg',
  `logo` VARCHAR(1024) COMMENT 'Logo | OrganizerBean.logo',
  `slogan` VARCHAR(512) COMMENT '标语 | OrganizerBean.slogan',
  `summary` TEXT COMMENT '简介 | OrganizerBean.summary',
  `fans_num` INT COMMENT '粉丝数 | OrganizerBean.fansNum',
  `activity_num` INT COMMENT '演出数 | OrganizerBean.activityNum',
  `activity_event_num` INT COMMENT '场次数 | OrganizerBean.activityEventNum',
  `category_ids` JSON COMMENT '分类（原 List<Integer>）| OrganizerBean.categoryIds',
  `activities` JSON COMMENT '演出（原 List<ActivityBean>）| OrganizerBean.activities',
  PRIMARY KEY (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='主办方 / 机构 | OrganizerBean（v3/home/organizer）';
