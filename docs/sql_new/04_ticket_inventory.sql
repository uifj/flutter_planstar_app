-- ========================================================================
--  sql_new（已修复版）· 04_ticket_inventory.sql
--  来源: docs/sql/04_ticket_inventory.sql  |  生成: tools/build_sql_new.py
--  与基线的差异:
--    R1 表尾显式 COLLATE=utf8mb4_unicode_ci（库/表/列三层排序规则统一）
--    R2 8 处关联 ID 由 INT 对齐为 BIGINT（消除 fk_pin_tuan_orders_pin_tuan_id 阻塞）
--    R3 4 处元数据代理主键补 COMMENT
--  为什么这样设计: 以上三项不改变列语义、不拒绝历史数据、不影响 267 个 REST 契约，
--    属于可确定性执行的规范类修复；会改变业务口径的提案全部留在 optional/PROPOSALS.sql。
--  基线 docs/sql/ 未被修改；本目录可独立用于 MySQL 8.0 全新空库安装。
--  验证边界: 见 VALIDATION.md（未做真实 MySQL 8.0 执行 / EXPLAIN / 压测 / HA 验证）。
-- ========================================================================

-- ========================================================================
--  04 · 票档 / 座位 / 库存
--  服务库: planstar_ticket
--  执行顺序: 01_init_databases.sql → 02 … 09 → 10 / 11 → 12_constraints.sql
--  本文件 6 张表: ticket_categories, ticket_groups, ticket_areas, ticket_seats, seat_map_layouts, discount_activities
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/tree/main/sql
--    NN_<域>.sql 按服务分库 + migrations/<库>/000001_init.up.sql / .down.sql
--  方言: MySQL 8.0 / InnoDB / utf8mb4（按用户选择保持，未切换 PostgreSQL）
--  第三方 SDK 表（小米推送 / 极光 JPush / 百度定位·mshield / Bugly /
--    字节 AppLog·bdtracker）共 31 张已按要求全部移除。
-- ========================================================================

USE `planstar_ticket`;

-- ----------------------------------------------------------------------
--  域 3 · 演出商品（show / goods）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ticket_categories` (
  `id` BIGINT NOT NULL COMMENT '票档ID | TicketCategory.id',
  `activity_event_id` BIGINT COMMENT '场次ID | TicketCategory.activityEventId',
  `activity_id` BIGINT COMMENT '演出ID | 推断',
  `specification` VARCHAR(256) COMMENT '规格/票档名 | TicketCategory.specification',
  `desc` TEXT COMMENT '描述 | TicketCategory.desc',
  `origin_price` DECIMAL(12,2) COMMENT '原价 | TicketCategory.originPrice',
  `low_price` DECIMAL(12,2) COMMENT '最低价 | TicketCategory.lowPrice',
  `discount_rate` DECIMAL(10,4) COMMENT '折扣率 | TicketCategory.discountRate',
  `discount_flag` TINYINT(1) COMMENT '有折扣 | TicketCategory.discountFlag',
  `price_lowest` TINYINT(1) COMMENT '最低价标记 | TicketCategory.priceLowest',
  `has_ticket` TINYINT(1) COMMENT '有票 | TicketCategory.hasTicket',
  `tickets_num` INT COMMENT '票数 | TicketCategory.ticketsNum',
  `unit_ticket_num` INT COMMENT '单位票数 | TicketCategory.unitTicketNum',
  `is_e_ticket` TINYINT(1) COMMENT '电子票 | TicketCategory.isETicket',
  `need_speed_pack_buy` TINYINT(1) COMMENT '需加速包 | TicketCategory.needSpeedPackBuy',
  `show_ticket_list` TINYINT(1) COMMENT '显示票列表 | TicketCategory.showTicketList',
  `icon` VARCHAR(1024) COMMENT '图标 | TicketCategory.icon',
  `seat_color` VARCHAR(64) COMMENT '座位颜色 | TicketCategory.seatColor',
  `status` INT COMMENT '状态 | TicketCategory.status',
  `areas` JSON COMMENT '区域（原 List<TicketAreaBean>）| TicketCategory.areas',
  `available_numbers` JSON COMMENT '可选数量（原 List<Integer>）| TicketCategory.availableNumbers',
  `proxy_buy_info` JSON COMMENT '代抢信息（原 ProxyBuyInfo）| TicketCategory.proxyBuyInfo',
  `add_time` BIGINT COMMENT '创建时间 | TicketCategory.addTime',
  `update_time` BIGINT COMMENT '更新时间 | TicketCategory.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_tc_event` (`activity_event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='票档 | TicketCategory（v4/ticketCategories · v5/ticketCategories）';

CREATE TABLE IF NOT EXISTS `ticket_groups` (
  `id` BIGINT NOT NULL COMMENT '票组ID | TicketGroup.id',
  `ticket_group_id` BIGINT COMMENT '票组ID（冗余）| TicketGroup.ticketGroupId',
  `ticket_category_id` BIGINT COMMENT '票档ID | TicketGroup.ticketCategoryId',
  `ticket_area_id` BIGINT COMMENT '区域ID | TicketGroup.ticketAreaId',
  `ticket_row_id` BIGINT COMMENT '排ID | TicketGroup.ticketRowId',
  `activity_event_id` BIGINT COMMENT '场次ID | 推断',
  `saler` BIGINT COMMENT '卖家ID | TicketGroup.saler',
  `saler_name` VARCHAR(128) COMMENT '卖家名 | TicketGroup.salerName',
  `sale_price` DECIMAL(12,2) COMMENT '售价 | TicketGroup.salePrice',
  `origin_price` DECIMAL(12,2) COMMENT '原价 | TicketGroup.originPrice',
  `specification` VARCHAR(256) COMMENT '规格 | TicketGroup.specification',
  `ticket_category_specification` VARCHAR(256) COMMENT '票档规格 | TicketGroup.ticketCategorySpecification',
  `area_name` VARCHAR(256) COMMENT '区域名 | TicketGroup.areaName',
  `desc` TEXT COMMENT '描述 | TicketGroup.desc',
  `ticket_category_desc` TEXT COMMENT '票档描述 | TicketGroup.ticketCategoryDesc',
  `count` INT COMMENT '数量 | TicketGroup.count',
  `sold` INT COMMENT '已售 | TicketGroup.sold',
  `selling_amount` INT COMMENT '在售数量 | TicketGroup.sellingAmount',
  `saling` INT COMMENT '在售标记 | TicketGroup.saling',
  `is_continuous_seat` TINYINT(1) COMMENT '连座 | TicketGroup.isContinuousSeat',
  `is_e_ticket` TINYINT(1) COMMENT '电子票 | TicketGroup.isETicket',
  `is_recommended` TINYINT(1) COMMENT '推荐 | TicketGroup.isRecommended',
  `promise_deliver_day` INT COMMENT '承诺发货天数 | TicketGroup.promiseDeliverDay',
  `promise_deliver_notice` TEXT COMMENT '发货承诺 | TicketGroup.promiseDeliverNotice',
  `row_index` INT COMMENT '排索引 | TicketGroup.rowIndex',
  `seat_color` VARCHAR(64) COMMENT '座位颜色 | TicketGroup.seatColor',
  `split_order_fee` DECIMAL(12,2) COMMENT '拆单费 | TicketGroup.splitOrderFee',
  `succeed_num` INT COMMENT '已成团数 | TicketGroup.succeedNum',
  `pin_tuan_campaign_item_id` BIGINT COMMENT '拼团项ID | TicketGroup.pinTuanCampaignItemId',
  `unit_ticket_num` INT COMMENT '单位票数 | TicketGroup.unitTicketNum',
  `full_view_image` VARCHAR(1024) COMMENT '全场图 | TicketGroup.fullViewImage',
  `sale_tag` VARCHAR(256) COMMENT '销售标签 | TicketGroup.saleTag',
  `num_max` INT COMMENT '最大购买数 | TicketGroup.numMax',
  `num_min` INT COMMENT '最小购买数 | TicketGroup.numMin',
  `sell_limit` INT COMMENT '限售 | TicketGroup.sellLimit',
  `speed_express` TINYINT(1) COMMENT '极速配送 | TicketGroup.speedExpress',
  `is_is_divide` TINYINT(1) COMMENT '是否可拆 | TicketGroup.isIsDivide',
  `addition` JSON COMMENT '附加项（原 AdditionBean）| TicketGroup.addition',
  `available_numbers` JSON COMMENT '可选数量（原 List<Integer>）| TicketGroup.availableNumbers',
  PRIMARY KEY (`id`),
  KEY `idx_tg_cat` (`ticket_category_id`),
  KEY `idx_tg_saler` (`saler`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='票组 / 挂单 | TicketGroup（v1/ticketGroup · v4/seats）';

CREATE TABLE IF NOT EXISTS `ticket_areas` (
  `id` BIGINT NOT NULL COMMENT '区域ID | TicketAreaBean.id',
  `area_name` VARCHAR(256) COMMENT '区域名 | TicketAreaBean.areaName',
  `height` INT COMMENT '高 | TicketAreaBean.height',
  `width` INT COMMENT '宽 | TicketAreaBean.width',
  `is_select` TINYINT(1) COMMENT '可选 | TicketAreaBean.isSelect',
  `sold_out` TINYINT(1) COMMENT '售罄 | TicketAreaBean.soldOut',
  `color` INT COMMENT '颜色（Flutter SeatArea.color）| Flutter',
  `label` VARCHAR(128) COMMENT '标签（Flutter）| Flutter',
  `stage_label` VARCHAR(128) COMMENT '舞台标签（Flutter SeatMapData）| Flutter',
  `rows` JSON COMMENT '排列表（原 List<TicketSeatBean> / Flutter List<SeatRow>）| TicketAreaBean.ticketSeats',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='选座区域 | TicketAreaBean + Flutter SeatArea';

CREATE TABLE IF NOT EXISTS `ticket_seats` (
  `id` BIGINT NOT NULL COMMENT '座位ID | TicketSeatBean.id',
  `area_id` BIGINT COMMENT '区域ID | Flutter Seat.areaName 关联',
  `area_name` VARCHAR(256) COMMENT '区域名 | Flutter Seat.areaName',
  `seat_row` VARCHAR(64) COMMENT '排 | TicketSeatBean.row',
  `seat_col` VARCHAR(64) COMMENT '列 | TicketSeatBean.col',
  `x` INT COMMENT 'X 坐标 | TicketSeatBean.x',
  `y` INT COMMENT 'Y 坐标 | TicketSeatBean.y',
  `z` INT COMMENT 'Z 坐标 | TicketSeatBean.z',
  `status` INT COMMENT '状态（0 可选 / 1 已售 / 2 锁定 / 3 通道 / 4 不可选，见 SeatStatus）| TicketSeatBean.status',
  `desc` VARCHAR(512) COMMENT '描述 | TicketSeatBean.desc',
  `price` DECIMAL(12,2) COMMENT '价格（Flutter）| Flutter Seat.price',
  `category_id` BIGINT COMMENT '票档ID（Flutter）| Flutter Seat.categoryId',
  `ticket_group_id` BIGINT COMMENT '票组ID | 推断',
  `ticket` JSON COMMENT '票快照（原 TicketGroup）| TicketSeatBean.ticket',
  PRIMARY KEY (`id`),
  KEY `idx_seat_area` (`area_id`),
  KEY `idx_seat_group` (`ticket_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='座位 | TicketSeatBean + Flutter Seat';

CREATE TABLE IF NOT EXISTS `seat_map_layouts` (
  `id` BIGINT NOT NULL COMMENT '布局ID | TicketTableBean.id',
  `activity_event_id` BIGINT COMMENT '场次ID | 推断',
  `venue_name` VARCHAR(256) COMMENT '场馆名（Flutter）| Flutter SeatMapData.venueName',
  `stage_label` VARCHAR(128) COMMENT '舞台标签（Flutter）| Flutter',
  `type` INT COMMENT '类型（见 dict_enums.TicketType）| TicketTableBean.type',
  `status` INT COMMENT '状态 | TicketTableBean.status',
  `has_full_view_image` TINYINT(1) COMMENT '是否有全场图 | TicketTableBean.hasFullViewImage',
  `icon_checked` VARCHAR(1024) COMMENT '选中图标 | TicketTableBean.iconChecked',
  `icon_unable` VARCHAR(1024) COMMENT '不可选图标 | TicketTableBean.iconUnable',
  `icon_un_checked` VARCHAR(1024) COMMENT '未选图标 | TicketTableBean.iconUnChecked',
  `icon_ticket_category` VARCHAR(1024) COMMENT '票档图标 | TicketTableBean.iconTicketCategory',
  `icon_unable_template` JSON COMMENT '模板（原 IconTemplateBean）| TicketTableBean.iconUnableTemplate',
  `package_discount` JSON COMMENT '套餐折扣（原 Map<String,Map<String,Double>>）| TicketTableBean.packageDiscount',
  `ticket_categories_icon` JSON COMMENT '票档图标映射 | TicketTableBean.ticketCategoriesIcon',
  `area_tickets` JSON COMMENT '区域票（原 List<TicketAreaBean>）| TicketTableBean.areaTickets',
  `ticket_categories` JSON COMMENT '票档（原 List<TicketCategory>）| TicketTableBean.ticketCategories',
  `areas` JSON COMMENT '区域（Flutter List<SeatArea>）| Flutter',
  `add_time` BIGINT COMMENT '创建时间 | TicketTableBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | TicketTableBean.updateTime',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='选座图布局 | TicketTableBean + Flutter SeatMapData';

CREATE TABLE IF NOT EXISTS `discount_activities` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `activity_event_id` BIGINT COMMENT '场次ID | DiscountActivityBean.activityEventId',
  `location_type` INT COMMENT '位置类型 | DiscountActivityBean.locationType',
  `origin_price` DECIMAL(12,2) COMMENT '原价 | DiscountActivityBean.originPrice',
  `sale_price` DECIMAL(12,2) COMMENT '售价 | DiscountActivityBean.salePrice',
  `ticket_category_id` BIGINT COMMENT '票档ID | DiscountActivityBean.ticketCategoryId',
  `ticket_group_id` BIGINT COMMENT '票组ID | DiscountActivityBean.ticketGroupId',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='折扣活动 | DiscountActivityBean（首页 discounts 楼层）';
