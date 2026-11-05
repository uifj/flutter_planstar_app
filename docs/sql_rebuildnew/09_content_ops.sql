-- ========================================================================
--  sql_rebuildnew · 09_content_ops.sql
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
--  09 · 运营位 / 搜索 / 增长
--  服务库: planstar_content
--  执行顺序: 01_init_databases.sql → 02 … 09 → 10 / 11 → 12_constraints.sql
--  本文件 8 张表: banners, ads, home_floors, op_positions, search_keywords, share_logs, feedback, tracking_events
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/tree/main/sql
--    NN_<域>.sql 按服务分库 + migrations/<库>/000001_init.up.sql / .down.sql
--  方言: MySQL 8.0 / InnoDB / utf8mb4（按用户选择保持，未切换 PostgreSQL）
--  第三方 SDK 表（小米推送 / 极光 JPush / 百度定位·mshield / Bugly /
--    字节 AppLog·bdtracker）共 31 张已按要求全部移除。
-- ========================================================================

USE `planstar_content`;

-- ----------------------------------------------------------------------
--  域 7 · 运营位 / 搜索 / 增长（ops / search / growth）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `banners` (
  `id` BIGINT NOT NULL COMMENT 'ID | Banner.id / AdBean.id',
  `type` INT COMMENT '类型 | Banner.type',
  `city_id` INT COMMENT '城市ID | Banner.cityId',
  `platform` INT COMMENT '平台 | Banner.platform',
  `poster` VARCHAR(1024) COMMENT '图片 | Banner.poster',
  `bg_color` VARCHAR(32) COMMENT '背景色 | Banner.bgColor',
  `schema` VARCHAR(1024) COMMENT '跳转 scheme | Banner.schema',
  `url` VARCHAR(1024) COMMENT '链接 | Banner.url',
  `sort` INT COMMENT '排序 | Banner.sort',
  `status` INT COMMENT '状态 | Banner.status',
  `from_time` BIGINT COMMENT '生效开始 | Banner.fromTime',
  `to_time` BIGINT COMMENT '生效结束 | Banner.toTime',
  `log_banner_id` INT COMMENT '埋点ID | Banner.logBannerId',
  `log_banner_type` VARCHAR(64) COMMENT '埋点类型 | Banner.logBannerType',
  `add_time` BIGINT COMMENT '创建时间 | Banner.addTime',
  `update_time` BIGINT COMMENT '更新时间 | Banner.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_banner_city` (`city_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='轮播图 / 广告位 | Banner / AdBean / HeaderBackgroundBean';

CREATE TABLE IF NOT EXISTS `ads` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `name` VARCHAR(256) COMMENT '名称 | IconsBean.name',
  `icon_tips` VARCHAR(512) COMMENT '图标提示 | IconsBean.iconTips',
  `poster` VARCHAR(1024) COMMENT '图片 | IconsBean.poster',
  `schema` VARCHAR(1024) COMMENT '跳转 | IconsBean.schema',
  `android_schema` VARCHAR(1024) COMMENT 'Android scheme | BenefitIconBean.androidSchema',
  `ios_schema` VARCHAR(1024) COMMENT 'iOS scheme | BenefitIconBean.iosSchema',
  `sub_title` VARCHAR(256) COMMENT '副标题 | BenefitIconBean.subTitle',
  `title` VARCHAR(256) COMMENT '标题 | BenefitIconBean.title',
  `url` VARCHAR(1024) COMMENT '链接 | BenefitIconBean.url',
  `icon` VARCHAR(1024) COMMENT '图标 | BenefitIconBean.icon',
  `click_num` INT COMMENT '点击数 | FeedAdBean.clickNum',
  `users` JSON COMMENT '用户列表（原 List<UserBean>）| FeedAdBean.users',
  `log_op_position_id` INT COMMENT '埋点运营位ID | HomeCenterOpBean.logOpPositionId',
  `log_banner_to_object_type` VARCHAR(64) COMMENT '埋点对象类型 | HomeCenterOpBean.logBannerToObjectType',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='运营图标 / 权益位 / 悬浮球 | IconsBean / BenefitIconBean / FeedAdBean / HomeCenterOpBean';

CREATE TABLE IF NOT EXISTS `home_floors` (
  `floor_id` VARCHAR(64) NOT NULL COMMENT '楼层ID | HomeFloorShowBean.floorId',
  `type` INT COMMENT '楼层类型（见 wiki 27 §5.1 三套编号）| HomeFloorBean.type',
  `title` VARCHAR(512) COMMENT '标题 | HomeFloorShowBean.title',
  `desc` TEXT COMMENT '描述 | HomeFloorShowBean.desc',
  `display_type` INT COMMENT '展示类型 | HomeFloorShowBean.displayType',
  `data` TEXT COMMENT '原始 JSON（HomeFloorBean.data 永久保留）| HomeFloorBean.data',
  `search_hint` VARCHAR(512) COMMENT '搜索提示 | HomeFloors.searchHint',
  `calendar_tip` JSON COMMENT '日历提示（原 CalendarTip）| HomeFloors.calendarTip',
  `actors` JSON COMMENT '艺人楼层（原 HomeActorsBean）| HomeFloorBean.actors',
  `banners` JSON COMMENT '轮播（原 List<? extends Banner>）| HomeFloorBean.banners',
  `center_op` JSON COMMENT '中央运营位（原 HomeCenterOpBean）| HomeFloorBean.centerOp',
  `choiceness` JSON COMMENT '精选（原 HomeChoicenessBean）| HomeFloorBean.choiceness',
  `discovery_wonder` JSON COMMENT '发现精彩 | HomeFloorBean.discoveryWonder',
  `guarantee` JSON COMMENT '保障（原 HomeGuaranteeBean）| HomeFloorBean.guarantee',
  `home_show_list` JSON COMMENT '演出列表（原 HomeShow）| HomeFloorBean.homeShowList',
  `hot_actor_sites` JSON COMMENT '热门艺人站点 | HomeFloorBean.hotActorSites',
  `hot_search_keywords` JSON COMMENT '热搜词 | HomeFloorBean.hotSearchKeywords',
  `hot_tour_list` JSON COMMENT '热门巡演 | HomeFloorBean.hotTourList',
  `op` JSON COMMENT '运营位列表 | HomeFloorBean.op',
  `recommend_word_list` JSON COMMENT '推荐词 | HomeFloorBean.recommendWordList',
  `recommends` JSON COMMENT '瀑布流（原 ArrayList<HomeWaterfallItem>）| HomeFloorBean.recommends',
  `shortcuts` JSON COMMENT '快捷入口 | HomeFloorBean.shortcuts',
  `theme_recommend` JSON COMMENT '主题推荐（原 HomeThemeRecommend）| HomeFloorBean.themeRecommend',
  `venues` JSON COMMENT '场馆楼层（原 HomeVenuesBean）| HomeFloorBean.venues',
  `waterfall` JSON COMMENT '瀑布流配置（原 HomeWaterfall）| HomeFloorBean.waterfall',
  PRIMARY KEY (`floor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='首页楼层 / 内容楼层 | HomeFloorBean / HomeFloors / HomeFloorShowBean / HomeShow';

CREATE TABLE IF NOT EXISTS `op_positions` (
  `id` BIGINT NOT NULL COMMENT 'ID | OperatingPositionBean.id / launchScreenBean.id',
  `template_id` INT COMMENT '模板ID | OpPosition.templateId',
  `inner_title` VARCHAR(256) COMMENT '内标题 | OperatingPositionBean.innerTitle',
  `main_title` VARCHAR(256) COMMENT '主标题 | HomeOpbean.mainTitle',
  `sub_title` VARCHAR(256) COMMENT '副标题 | OperatingPositionBean.subTitle',
  `title` VARCHAR(256) COMMENT '标题 | OperatingPositionBean.title',
  `poster` VARCHAR(1024) COMMENT '图片 | OperatingPositionBean.poster',
  `poster_url` VARCHAR(1024) COMMENT '图片 URL | HomeOpbean.posterUrl',
  `schema` VARCHAR(1024) COMMENT '跳转 | OperatingPositionBean.schema',
  `style_type` INT COMMENT '样式类型 | HomeOpbean.styleType',
  `sub_type` INT COMMENT '子类型 | HomeOpbean.subType',
  `activity_id` BIGINT COMMENT '演出ID | HomeOpbean.activityId',
  `actor_name` VARCHAR(256) COMMENT '艺人名 | HomeOpbean.actorName',
  `low_price` DECIMAL(12,2) COMMENT '最低价 | HomeOpbean.lowPrice',
  `name` VARCHAR(256) COMMENT '名称 | HomeOpbean.name',
  `sold_out` TINYINT COMMENT '售罄 | HomeOpbean.soldOut',
  `data` JSON COMMENT '数据体（原 JSONObject / DataBean）| OpPosition.data',
  `items` JSON COMMENT '条目（原 List<HomeOpItemData>）| HomeOpbean.items',
  `icon` VARCHAR(1024) COMMENT '图标 | PopBoxBean.icon',
  `icon_schema` VARCHAR(1024) COMMENT '图标跳转 | PopBoxBean.iconSchema',
  `key` VARCHAR(128) COMMENT '键 | PopBoxBean.key',
  `type` VARCHAR(64) COMMENT '类型 | PopBoxBean.type',
  `url` VARCHAR(1024) COMMENT '链接 | PopBoxBean.url',
  `city_id` INT COMMENT '城市ID | launchScreenBean.cityId',
  `duration` INT COMMENT '时长 | launchScreenBean.duration',
  `video` VARCHAR(1024) COMMENT '视频 | launchScreenBean.video',
  `open_screen_type` VARCHAR(64) COMMENT '开屏类型 | launchScreenBean.openScreenType',
  `from_time` BIGINT COMMENT '生效开始 | launchScreenBean.fromTime',
  `to_time` BIGINT COMMENT '生效结束 | launchScreenBean.toTime',
  `status` INT COMMENT '状态 | launchScreenBean.status',
  `add_time` BIGINT COMMENT '创建时间 | launchScreenBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | launchScreenBean.updateTime',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='运营位 / 弹窗 / 启动屏 | OpPosition / OperatingPositionBean / PopBoxBean / launchScreenBean / HomeOpbean';

CREATE TABLE IF NOT EXISTS `search_keywords` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `keyword` VARCHAR(256) COMMENT '关键词 | SchemaKeywordBean.keyword',
  `recommend_word` VARCHAR(256) COMMENT '推荐词 | SchemaKeywordBean.recommendWord',
  `schema` VARCHAR(1024) COMMENT '跳转 | SchemaKeywordBean.schema',
  `log_id` INT COMMENT '埋点ID | SchemaKeywordRankBean.logId',
  `pn_local_rank` INT COMMENT '本地排名 | SchemaKeywordRankBean.pnLocalRank',
  `name` VARCHAR(256) COMMENT '名称 | SearchSuggestBean.name',
  `type` VARCHAR(64) COMMENT '类型 | SearchSuggestBean.type',
  `label` VARCHAR(256) COMMENT '展示文案 | Flutter HotKeyword.label',
  `word` VARCHAR(256) COMMENT '词 | Flutter HotKeyword.word',
  `hit_count` INT COMMENT '热度 | Flutter HotKeyword.hitCount',
  `hot` TINYINT COMMENT '是否热 | Flutter HotKeyword.hot',
  `key` VARCHAR(128) COMMENT '搜索键 | SearchOption.key',
  `seat_map` VARCHAR(64) COMMENT '选座 | SearchOption.seatMap',
  `sort` VARCHAR(64) COMMENT '排序 | SearchOption.sort',
  `start_time` BIGINT COMMENT '开始时间 | SearchOption.startTime',
  `end_time` BIGINT COMMENT '结束时间 | SearchOption.endTime',
  `time` VARCHAR(128) COMMENT '时间 | SearchOption.time',
  PRIMARY KEY (`id`),
  KEY `idx_searchkw_word` (`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='热搜词 / 联想词 / 搜索条件 | SchemaKeywordBean / SchemaKeywordRankBean / SearchSuggestBean / SearchOption / HotKeyword';

CREATE TABLE IF NOT EXISTS `share_logs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `subject_type` INT COMMENT '主体类型 | 推断',
  `subject_id` BIGINT COMMENT '主体ID | 推断',
  `channel` VARCHAR(64) COMMENT '渠道（WECHAT / MOMENTS / WEIBO / QQ / QZONE）| dict_enums.ShareChannelType',
  `title` VARCHAR(512) COMMENT '标题 | ShareModel.title / ShareParams.title',
  `desc` TEXT COMMENT '描述 | ShareModel.desc / ShareParams.desc',
  `image_url` VARCHAR(1024) COMMENT '图片 | ShareModel.imageURL',
  `share_image_url` VARCHAR(1024) COMMENT '分享图 | ShareModel.shareImageUrl',
  `img_url` VARCHAR(1024) COMMENT '分享图 | ShareParams.imgUrl',
  `url` VARCHAR(1024) COMMENT '链接 | ShareModel.url',
  `mp_url` VARCHAR(1024) COMMENT '小程序链接 | ShareModel.mpUrl',
  `mp_image_url` VARCHAR(1024) COMMENT '小程序图 | ShareModel.mpImageUrl',
  `link` VARCHAR(1024) COMMENT '链接 | ShareParams.link',
  `mp_link` VARCHAR(1024) COMMENT '小程序链接 | ShareParams.mpLink',
  `share_reward_confirm` TINYINT COMMENT '分享奖励确认 | v1/shareReward/confirm',
  `add_time` BIGINT COMMENT '分享时间 | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_share_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分享记录 / 分享参数 | ShareModel / ShareParams / ShareChannelType / v1/share/log';

CREATE TABLE IF NOT EXISTS `feedback` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `content` TEXT COMMENT '反馈内容 | 推断',
  `contact` VARCHAR(256) COMMENT '联系方式 | 推断',
  `type` INT COMMENT '类型 | 推断',
  `status` INT COMMENT '状态 | 推断',
  `images` JSON COMMENT '图片列表 | 推断',
  `add_time` BIGINT COMMENT '创建时间 | 推断',
  `update_time` BIGINT COMMENT '更新时间 | 推断',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='意见反馈 | v1/feedback';

CREATE TABLE IF NOT EXISTS `tracking_events` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `action` VARCHAR(64) COMMENT '动作（点击 / enter）| PNLogAction',
  `key` VARCHAR(128) COMMENT '事件 key | PNLogger',
  `keyname` VARCHAR(256) COMMENT '事件名 | PNLogger',
  `schema` VARCHAR(256) COMMENT '页面 scheme | PNSchemeMap',
  `schemaname` VARCHAR(256) COMMENT '页面名 | PNSchemeMap',
  `params` JSON COMMENT '参数 | PNLogger.sendLog',
  `city_id` INT COMMENT '城市ID | 埋点公共字段',
  `dvid` VARCHAR(128) COMMENT '设备ID | 埋点公共字段',
  `user_id` BIGINT COMMENT '用户ID | 埋点公共字段',
  `channel` VARCHAR(128) COMMENT '渠道 | 埋点公共字段',
  `referer` VARCHAR(256) COMMENT '来源页 | 埋点公共字段',
  `add_time` BIGINT COMMENT '事件时间 | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_track_user` (`user_id`,`add_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='埋点事件 | PNLogger / PNLogUploader（https://track 域/log）';
