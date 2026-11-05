-- ========================================================================
--  sql_rebuildnew · 05_order.sql
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
--  05 · 订单
--  服务库: planstar_order
--  执行顺序: 01_init_databases.sql → 02 … 09 → 10 / 11 → 12_constraints.sql
--  本文件 10 张表: orders, order_events, order_items, order_goods, order_goods_packages, order_deliveries, order_confirm_snapshots, order_postage, order_comments, speed_packs
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/tree/main/sql
--    NN_<域>.sql 按服务分库 + migrations/<库>/000001_init.up.sql / .down.sql
--  方言: MySQL 8.0 / InnoDB / utf8mb4（按用户选择保持，未切换 PostgreSQL）
--  第三方 SDK 表（小米推送 / 极光 JPush / 百度定位·mshield / Bugly /
--    字节 AppLog·bdtracker）共 31 张已按要求全部移除。
-- ========================================================================

USE `planstar_order`;

-- ----------------------------------------------------------------------
--  域 4 · 交易与支付（order / payment / refund）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` BIGINT NOT NULL COMMENT '订单ID | unifiedOrder.orderId',
  `order_number` VARCHAR(64) COMMENT '订单号 | Flutter OrderNumber.value',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `activity_id` BIGINT COMMENT '演出ID | 推断',
  `activity_event_id` BIGINT COMMENT '场次ID | 推断',
  `shop_id` BIGINT COMMENT '店铺ID | 推断',
  `business_order_id` BIGINT COMMENT '业务订单ID | OrderItem.businessOrderId',
  `business_order_type` INT COMMENT '业务订单类型 | OrderItem.businessOrderType',
  `order_type` INT COMMENT '订单类型（1 普通票 / 2 拼团 / 5 抢票 / 60 Plus会员 / 70 加速包，见 dict_enums.OrderType）| MakeOrderRequestBody.orderType',
  `subject_type` INT COMMENT '支付主体类型（9 普通 / 6 会员充值 / 2 拼团 / 60 Plus，见 dict_enums.SubjectType）| gotoPayActivity 硬编码',
  `status` INT COMMENT '订单状态（见 dict_enums.OrderStatus）| OrderEvent.currentStatus',
  `order_status_desc` VARCHAR(256) COMMENT '状态文案 | OrderItem.orderStatusDesc',
  `order_type_desc` VARCHAR(256) COMMENT '类型文案 | OrderItem.orderTypeDesc',
  `order_type_desc_rgb` VARCHAR(64) COMMENT '类型文案色值 | OrderItem.orderTypeDescRGB',
  `title` VARCHAR(512) COMMENT '标题 | OrderItem.title',
  `poster` VARCHAR(1024) COMMENT '海报 | OrderItem.poster',
  `order_amount_desc` VARCHAR(256) COMMENT '金额文案 | OrderItem.orderAmountDesc',
  `descs` JSON COMMENT '描述行（原 List<String>）| OrderItem.descs',
  `spec` JSON COMMENT '规格（原 List<Spec>）| OrderItem.spec',
  `buttons` JSON COMMENT '操作按钮（原 List<OrderButtonBean>）| OrderItem.buttons',
  `pay_amount` DECIMAL(12,2) COMMENT '实付金额 | MakeOrderRequestBody.payAmount',
  `total_amount` DECIMAL(12,2) COMMENT '订单总额 | MakeOrderRequestBody.totalAmount',
  `good_total_amount` DECIMAL(12,2) COMMENT '商品总额 | OrderConfirmInfo.goodTotalAmount',
  `postage` DECIMAL(12,2) COMMENT '运费 | MakeOrderRequestBody.postage',
  `discount_amount` DECIMAL(12,2) COMMENT '优惠金额 | 推断',
  `split_order_fee` DECIMAL(12,2) COMMENT '拆单费 | BizParam.splitOrderContext.splitOrderFee',
  `consume_amount` DECIMAL(12,2) COMMENT '消费金额 | MakeOrderRequestBody.consumeAmount',
  `coupon_ids` JSON COMMENT '使用的券ID（与 campaignIds 互斥）| MakeOrderRequestBody.couponIds',
  `campaign_ids` JSON COMMENT '使用的活动ID（与 couponIds 互斥）| MakeOrderRequestBody.campaignIds',
  `gift_cards` JSON COMMENT '使用的礼品卡（原 List<GiftCard>）| MakeOrderRequestBody.giftCards',
  `goods` JSON COMMENT '商品（原 List<Goods>）| MakeOrderRequestBody.goods',
  `deliver` JSON COMMENT '配送（原 Deliver）| MakeOrderRequestBody.deliver',
  `additions` JSON COMMENT '附加项（原 List<? extends JSONObject>）| MakeOrderRequestBody.additions',
  `real_name_info_ids` JSON COMMENT '实名信息ID（原 List<Integer>）| MakeOrderRequestBody.realNameInfoIds',
  `biz_param` JSON COMMENT '业务参数（原 BizParam）| MakeOrderRequestBody.bizParam',
  `confirm_snapshot` JSON COMMENT '确认页快照（原 ConfirmSnapshot）| MakeOrderRequestBody.confirmSnapshot',
  `channel_attribute_info` TEXT COMMENT '渠道归因（自嵌套 JSON 字符串）| MakeOrderRequestBody.channelAttributeInfo',
  `id_card` VARCHAR(128) COMMENT '证件号 | MakeOrderRequestBody.idCard',
  `id_card_type` INT COMMENT '证件类型 | MakeOrderRequestBody.idCardType',
  `name` VARCHAR(128) COMMENT '收件人 | MakeOrderRequestBody.name',
  `phone` VARCHAR(64) COMMENT '联系电话 | MakeOrderRequestBody.phone',
  `user_address_id` BIGINT COMMENT '地址ID | MakeOrderRequestBody.userAddressId',
  `is_continuous_seat` TINYINT COMMENT '是否连座 | MakeOrderRequestBody.isContinuousSeat',
  `price_guarantee_type` INT COMMENT '保价类型 | MakeOrderRequestBody.priceGuaranteeType',
  `pin_tuan_id` BIGINT COMMENT '拼团ID | MakeOrderRequestBody.pinTuanId',
  `balance_speed_pack` INT COMMENT '加速包余额部分 | MakeOrderRequestBody.balanceSpeedPack',
  `cash_speed_pack` INT COMMENT '加速包现金部分 | MakeOrderRequestBody.cashSpeedPack',
  `channel` VARCHAR(128) COMMENT '渠道 | BizParam.channel',
  `pay_after_use` TINYINT COMMENT '先用后付 | PayAfterUseInfo.check',
  `credit_pay` TINYINT COMMENT '信用付 | CreditPay',
  `success_page` VARCHAR(1024) COMMENT '支付成功跳转 | PayInfo.successPage',
  `fail_page` VARCHAR(1024) COMMENT '支付失败跳转 | PayInfo.failPage',
  `refund_amount` DECIMAL(12,2) COMMENT '已退金额 | 推断',
  `add_time` BIGINT COMMENT '下单时间 | 推断',
  `pay_time` BIGINT COMMENT '支付时间 | 推断',
  `update_time` BIGINT COMMENT '更新时间 | 推断',
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_number` (`order_number`),
  KEY `idx_order_user` (`user_id`,`status`),
  KEY `idx_order_act` (`activity_id`),
  KEY `idx_order_addtime` (`add_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='统一订单 | unifiedOrder · OrderItem · MakeOrderRequestBody · OrderEvent';

CREATE TABLE IF NOT EXISTS `order_events` (
  `id` BIGINT NOT NULL COMMENT '事件ID | OrderEvent.id',
  `order_id` BIGINT COMMENT '订单ID | OrderEvent.orderId',
  `origin_status` INT COMMENT '原状态 | OrderEvent.originStatus',
  `current_status` INT COMMENT '新状态 | OrderEvent.currentStatus',
  `operator_id` BIGINT COMMENT '操作人 | OrderEvent.operatorId',
  `operator_type` INT COMMENT '操作人类型 | OrderEvent.operatorType',
  `supplement` TEXT COMMENT '补充说明 | OrderEvent.supplement',
  `add_time` BIGINT COMMENT '发生时间 | OrderEvent.addTime',
  `update_time` BIGINT COMMENT '更新时间 | OrderEvent.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_orderev_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单状态流转事件 | OrderEvent（v1/unifiedOrder/{orderId}/status）';

CREATE TABLE IF NOT EXISTS `order_items` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `order_id` BIGINT COMMENT '订单ID | OrderItem.orderId',
  `business_order_id` BIGINT COMMENT '业务订单ID | OrderItem.businessOrderId',
  `business_order_type` INT COMMENT '业务订单类型 | OrderItem.businessOrderType',
  `title` VARCHAR(512) COMMENT '标题 | OrderItem.title',
  `poster` VARCHAR(1024) COMMENT '海报 | OrderItem.poster',
  `order_status_desc` VARCHAR(256) COMMENT '状态文案 | OrderItem.orderStatusDesc',
  `order_type_desc` VARCHAR(256) COMMENT '类型文案 | OrderItem.orderTypeDesc',
  `order_type_desc_rgb` VARCHAR(64) COMMENT '色值 | OrderItem.orderTypeDescRGB',
  `order_amount_desc` VARCHAR(256) COMMENT '金额文案 | OrderItem.orderAmountDesc',
  `descs` JSON COMMENT '描述行 | OrderItem.descs',
  `spec` JSON COMMENT '规格（原 List<Spec>）| OrderItem.spec',
  `buttons` JSON COMMENT '按钮（原 List<OrderButtonBean>）| OrderItem.buttons',
  PRIMARY KEY (`id`),
  KEY `idx_orderitem_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单列表条目 | OrderItem（v1/unifiedOrder/myOrders）';

CREATE TABLE IF NOT EXISTS `order_goods` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `good_id` BIGINT COMMENT '商品/票组ID | Goods.goodId',
  `count` INT COMMENT '数量 | Goods.count',
  PRIMARY KEY (`id`),
  KEY `idx_ogoods_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单商品行 | Goods / GoodsBean';

CREATE TABLE IF NOT EXISTS `order_goods_packages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `activity_id` BIGINT COMMENT '演出ID | GoodsPackage.activityId',
  `activity_name` VARCHAR(512) COMMENT '演出名 | GoodsPackage.activityName',
  `activity_event_name` VARCHAR(512) COMMENT '场次名 | GoodsPackage.activityEventName',
  `venue_name` VARCHAR(256) COMMENT '场馆名 | GoodsPackage.venueName',
  `poster` VARCHAR(1024) COMMENT '海报 | GoodsPackage.poster',
  `detail_type` INT COMMENT '明细类型 | GoodsPackage.detailType',
  `non_refundable_exchangeable` TINYINT COMMENT '不可退可换 | GoodsPackage.nonRefundableExchangeable',
  `shop_info` JSON COMMENT '店铺（原 ShopInfo）| GoodsPackage.shopInfo',
  `speed_express` TINYINT COMMENT '极速配送 | GoodsPackage.speedExpress',
  `deliver_types` JSON COMMENT '配送方式（原 List<Integer>）| GoodsPackage.deliverTypes',
  `goods` JSON COMMENT '商品（原 List<Goods>）| GoodsPackage.goods',
  `details` JSON COMMENT '明细（原 List<Detail>）| GoodsPackage.details',
  `deliver_notice` TEXT COMMENT '配送须知 | GoodsPackage.deliverNotice',
  `shop_notice` TEXT COMMENT '卖家须知 | GoodsPackage.shopNotice',
  `count` INT COMMENT '数量 | GoodsPackage.count',
  `has_seat` TINYINT COMMENT '有座 | GoodsPackage.hasSeat',
  `sale_price` DECIMAL(12,2) COMMENT '售价 | GoodsPackage.salePrice',
  `ticket_category_specification` VARCHAR(256) COMMENT '票档规格 | GoodsPackage.ticketCategorySpecification',
  `seat_name` VARCHAR(256) COMMENT '座位名 | GoodsPackage.seatName',
  `area_show` TINYINT COMMENT '显示区域 | GoodsPackage.areaShow',
  `continue_seat` TINYINT COMMENT '连座 | GoodsPackage.continueSeat',
  `tips` JSON COMMENT '提示集合（原 Tips）| GoodsPackage.tips',
  `no_ticket_compensate_tip` JSON COMMENT '无票赔付提示 | GoodsPackage.noTicketCompensateTip',
  `no_ticket_onsite_compensate_tip` JSON COMMENT '现场无票赔付提示 | GoodsPackage.noTicketOnsiteCompensateTip',
  `refund_tip` JSON COMMENT '退款提示 | GoodsPackage.refundTip',
  `snap_up_fail_tip` JSON COMMENT '抢票失败提示 | GoodsPackage.snapUpFailTip',
  `snap_up_un_finish_tip` JSON COMMENT '抢票未完成提示 | GoodsPackage.snapUpUnFinishTip',
  PRIMARY KEY (`id`),
  KEY `idx_ogpkg_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品包 | GoodsPackage（确认页 goodPackages）';

CREATE TABLE IF NOT EXISTS `order_deliveries` (
  `id` BIGINT NOT NULL COMMENT '配送ID | Deliver.id',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `type` INT COMMENT '配送类型（见 dict_enums.DeliverType）| Deliver.type',
  `tip` VARCHAR(1024) COMMENT '提示 | Deliver.tip',
  `desc` TEXT COMMENT '描述 | Deliver.desc',
  `amount` DECIMAL(12,2) COMMENT '运费金额 | Deliver.amount / Postage.amount',
  `postage` JSON COMMENT '运费（原 Postage）| Deliver.postage',
  `postage_origin` DECIMAL(12,2) COMMENT '原运费 | PostageBean.postageOrigin',
  `postage_desc` VARCHAR(512) COMMENT '运费说明 | PostageBean.postageDesc',
  `address` JSON COMMENT '地址快照（原 Address）| Deliver.address',
  `contact` JSON COMMENT '联系人（原 Contact）| Deliver.contact',
  `additions` JSON COMMENT '附加项（原 List<Addition>）| Deliver.additions',
  `name` VARCHAR(128) COMMENT '收件人 | Deliver.name',
  `phone` VARCHAR(64) COMMENT '电话 | Deliver.phone',
  `district` VARCHAR(128) COMMENT '区县 | Deliver.district',
  `value` VARCHAR(512) COMMENT '值 | Deliver.value',
  `contact_phone` VARCHAR(64) COMMENT '联系电话 | DeliverBean.contactPhone',
  `deliver_tip` TEXT COMMENT '配送提示 | DeliverBean.deliverTip',
  `need_id_card` VARCHAR(64) COMMENT '是否需证件 | DeliverBean.needIdCard',
  `self_get_address` VARCHAR(1024) COMMENT '自取地址 | DeliverBean.selfGetAddress',
  `self_get_time` VARCHAR(256) COMMENT '自取时间 | DeliverBean.selfGetTime',
  `multi_deliver_group` TINYINT COMMENT '多配送组 | OrderConfirmInfo.multiDeliverGroup',
  `check` TINYINT COMMENT '是否勾选 | OrderConfirmInfo.check',
  `remark` TEXT COMMENT '备注 | OrderConfirmInfo.remark',
  PRIMARY KEY (`id`),
  KEY `idx_odel_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送 / 自取 / 电子票 | Deliver / DeliverBean / DeliverInfo / Postage / Contact / Addition';

CREATE TABLE IF NOT EXISTS `order_confirm_snapshots` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `ad_tips` VARCHAR(1024) COMMENT '广告提示 | OrderConfirmInfo.adTips',
  `good_total_amount` DECIMAL(12,2) COMMENT '商品总额 | OrderConfirmInfo.goodTotalAmount',
  `group_buy_rule_desc_for_c` TEXT COMMENT '拼团规则 | OrderConfirmInfo.groupBuyRuleDescForC',
  `price_guarantee_type` INT COMMENT '保价类型 | OrderConfirmInfo.priceGuaranteeType',
  `need_plus_member` TINYINT COMMENT '需 Plus 会员 | OrderConfirmInfo.needPlusMember',
  `can_buy` TINYINT COMMENT '可购买 | OrderConfirmInfo.canBuy',
  `reason` VARCHAR(1024) COMMENT '不可购买原因 | OrderConfirmInfo.reason',
  `count` INT COMMENT '数量 | OrderConfirmInfo.count',
  `need_id_card` TINYINT COMMENT '需实名 | OrderConfirmInfo.needIdCard',
  `need_id_card_v2` TINYINT COMMENT '需实名 V2 | OrderConfirmInfoBean.needIdCardV2',
  `id_card_count` INT COMMENT '观演人数量 | OrderConfirmInfoBean.idCardCount',
  `can_use` TINYINT COMMENT '券/卡可用 | OrderConfirmInfo.canUse',
  `error` VARCHAR(1024) COMMENT '错误 | OrderConfirmInfo.error',
  `content` TEXT COMMENT '内容 | OrderConfirmInfo.content',
  `schema` VARCHAR(1024) COMMENT '跳转 | OrderConfirmInfo.schema',
  `desc` TEXT COMMENT '描述 | OrderConfirmInfo.desc',
  `title` VARCHAR(512) COMMENT '标题 | OrderConfirmInfo.title',
  `remark` TEXT COMMENT '备注 | OrderConfirmInfo.remark',
  `notice` TEXT COMMENT '须知 | OrderConfirmInfoBean.notice',
  `notice_schema` VARCHAR(1024) COMMENT '须知跳转 | OrderConfirmInfoBean.noticeSchema',
  `refund_tip` TEXT COMMENT '退款提示 | OrderConfirmInfoBean.refundTip',
  `service_charge_title` VARCHAR(256) COMMENT '服务费标题 | OrderConfirmInfoBean.serviceChargeTitle',
  `service_charge_desc` TEXT COMMENT '服务费说明 | OrderConfirmInfoBean.serviceChargeDesc',
  `service_charge_open` TINYINT COMMENT '服务费开关 | OrderConfirmInfoBean.serviceChargeOpen',
  `promise_deliver_notice` TEXT COMMENT '发货承诺 | OrderConfirmInfoBean.promiseDeliverNotice',
  `no_ticket_compensate_switch` TINYINT COMMENT '无票赔付开关 | OrderConfirmInfoBean.noTicketCompensateSwitch',
  `only_plus_member_can_buy` TINYINT COMMENT '仅会员可买 | OrderConfirmInfoBean.onlyPlusMemberCanBuy',
  `can_refund` TINYINT COMMENT '可退 | OrderConfirmInfoBean.canRefund',
  `area_name` VARCHAR(256) COMMENT '区域名 | OrderConfirmInfoBean.areaName',
  `biz_param` JSON COMMENT '业务参数 | OrderConfirmInfo.bizParam',
  `campaign` JSON COMMENT '活动 | OrderConfirmInfo.campaign',
  `can_buy_info` JSON COMMENT '限购信息 | OrderConfirmInfo.canBuyInfo',
  `credit_pay` JSON COMMENT '信用付 | OrderConfirmInfo.creditPay',
  `pay_after_use_info` JSON COMMENT '先用后付 | OrderConfirmInfo.payAfterUseInfo',
  `plus_member` JSON COMMENT 'Plus 会员 | OrderConfirmInfo.plusMember',
  `id_card` JSON COMMENT '实名 | OrderConfirmInfo.idCard',
  `id_card_types` JSON COMMENT '证件类型（原 ArrayList<IDCardType>）| OrderConfirmInfo.idCardTypes',
  `coupon` JSON COMMENT '券 | OrderConfirmInfo.coupon',
  `gift_card` JSON COMMENT '礼品卡 | OrderConfirmInfo.giftCard',
  `addition_components` JSON COMMENT '附加组件（原 List<OrderConfirmExtraInfoBean>）| OrderConfirmInfo.additionComponents',
  `good_packages` JSON COMMENT '商品包（原 List<GoodsPackage>）| OrderConfirmInfo.goodPackages',
  `tip` JSON COMMENT '提示（原 Tip）| OrderConfirmInfo.tip',
  `deliver` JSON COMMENT '配送（原 DeliverInfo）| OrderConfirmInfo.deliver',
  `details` JSON COMMENT '配送明细（原 List<Deliver>）| OrderConfirmInfo.details',
  `campaigns` JSON COMMENT '活动列表（原 List<Campaign>）| OrderConfirmInfo.campaigns',
  `enable_coupons` JSON COMMENT '可用券（原 List<Coupon>）| OrderConfirmInfo.enableCoupons',
  `disable_coupons` JSON COMMENT '不可用券 | OrderConfirmInfo.disableCoupons',
  `notice_obj` JSON COMMENT '通知对象 | OrderConfirmInfo.notice',
  `trade` JSON COMMENT '交易说明 | OrderConfirmInfo.trade',
  `discount` JSON COMMENT '折扣 | OrderConfirmInfo.discount',
  `activity` JSON COMMENT '演出快照 | OrderConfirmInfoBean.activity',
  `activity_event` JSON COMMENT '场次快照 | OrderConfirmInfoBean.activityEvent',
  `address` JSON COMMENT '地址快照 | OrderConfirmInfoBean.address',
  `postage` JSON COMMENT '运费 | OrderConfirmInfoBean.postage',
  `speed_packs` JSON COMMENT '加速包（原 List<JSONObject>）| OrderConfirmInfoBean.speedPacks',
  `speed_packs_balance` JSON COMMENT '加速包余额 | OrderConfirmInfoBean.speedPacksBalance',
  `order_group_products` JSON COMMENT '订单组商品 | OrderConfirmInfoBean.orderGroupProducts',
  `ticket_category` JSON COMMENT '票档 | OrderConfirmInfoBean.ticketCategory',
  `venue` JSON COMMENT '场馆 | OrderConfirmInfoBean.venue',
  `goods` JSON COMMENT '商品（原 List<Goods>）| OrderConfirmInfoRequestBody.goods',
  `order_type` INT COMMENT '订单类型 | OrderConfirmInfoRequestBody.orderType',
  PRIMARY KEY (`id`),
  KEY `idx_ocs_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='确认订单页快照 | OrderConfirmInfo / OrderConfirmInfoBean / OrderConfirmInfoRequestBody';

CREATE TABLE IF NOT EXISTS `order_postage` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `postage` DECIMAL(12,2) COMMENT '运费 | PostageBean.postage',
  `postage_desc` VARCHAR(512) COMMENT '运费说明 | PostageBean.postageDesc',
  `postage_origin` DECIMAL(12,2) COMMENT '原运费 | PostageBean.postageOrigin',
  `deliver_type` INT COMMENT '配送类型 | 推断',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='运费试算 | PostageBean（v1/order/postage）';

CREATE TABLE IF NOT EXISTS `order_comments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `comment` JSON COMMENT '评价内容 | OrderCommentBean.comment',
  `reviews` JSON COMMENT '评价列表（原 List<Review>）| OrderCommentBean.reviews',
  `schema` JSON COMMENT '评价项（原 List<CommentSchemeBean>）| OrderCommentBean.schema',
  `rank` INT COMMENT '星级 | Review.rank',
  `content` TEXT COMMENT '内容 | Review.content',
  `add_time` BIGINT COMMENT '创建时间 | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_ocomment_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单评价 | OrderCommentBean / unifiedOrderComment';

CREATE TABLE IF NOT EXISTS `speed_packs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `amount` INT COMMENT '加速包金额 | SpeedPackChoice.amount',
  `desc` VARCHAR(512) COMMENT '描述 | SpeedPackChoice.desc',
  `recommend` TINYINT COMMENT '是否推荐 | SpeedPackChoice.recommend',
  `success_rate` DECIMAL(10,4) COMMENT '成功率 | SpeedPackChoice.successRate',
  `speed_pack_balance` INT COMMENT '加速包余额 | BizParam.speedPackBalance',
  `balance_speed_pack` INT COMMENT '余额抵扣部分 | MakeOrderRequestBody.balanceSpeedPack',
  `cash_speed_pack` INT COMMENT '现金部分 | MakeOrderRequestBody.cashSpeedPack',
  `speed_pack_choices` JSON COMMENT '选项列表（原 List<SpeedPackChoice>）| BizParam.speedPackChoices',
  `split_order_desc` VARCHAR(1024) COMMENT '拆单说明 | SplitOrderContext.splitOrderDesc',
  `split_order_fee` DECIMAL(12,2) COMMENT '拆单费 | SplitOrderContext.splitOrderFee',
  `channel` VARCHAR(128) COMMENT '渠道 | BizParam.channel',
  `expire_time` BIGINT COMMENT '过期时间 | BizParam.expireTime',
  `pin_tuan_id` BIGINT COMMENT '拼团ID | BizParam.pinTuanId',
  PRIMARY KEY (`id`),
  KEY `idx_speed_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='加速包 / 拆单参数 | SpeedPackChoice / BizParam / SplitOrderContext';
