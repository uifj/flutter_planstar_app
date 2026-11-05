-- ========================================================================
--  sql_new（已修复版）· 06_payment.sql
--  来源: docs/sql/06_payment.sql  |  生成: tools/build_sql_new.py
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
--  06 · 支付 / 退款 / 钱包 / 礼品卡
--  服务库: planstar_payment
--  执行顺序: 01_init_databases.sql → 02 … 09 → 10 / 11 → 12_constraints.sql
--  本文件 7 张表: payments, payment_channels, refunds, wallet_accounts, wallet_sequences, gift_cards, gift_card_usages
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/tree/main/sql
--    NN_<域>.sql 按服务分库 + migrations/<库>/000001_init.up.sql / .down.sql
--  方言: MySQL 8.0 / InnoDB / utf8mb4（按用户选择保持，未切换 PostgreSQL）
--  第三方 SDK 表（小米推送 / 极光 JPush / 百度定位·mshield / Bugly /
--    字节 AppLog·bdtracker）共 31 张已按要求全部移除。
-- ========================================================================

USE `planstar_payment`;

-- ----------------------------------------------------------------------
--  域 4 · 交易与支付（order / payment / refund）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `payments` (
  `pay_id` BIGINT NOT NULL COMMENT '支付单ID | 推断',
  `order_id` BIGINT COMMENT '订单ID | PayInfo.orderId',
  `left_time` INT COMMENT '剩余支付秒数（倒计时基线）| PayInfo.leftTime',
  `pay_amount` DECIMAL(12,2) COMMENT '应付金额 | PayInfo.payAmount',
  `balance` DECIMAL(12,2) COMMENT '可用余额 | PayInfo.balance',
  `title` VARCHAR(512) COMMENT '标题 | PayInfo.title',
  `value` VARCHAR(512) COMMENT '值 | PayInfo.value',
  `content` TEXT COMMENT '内容 | PayInfo.content',
  `schema` VARCHAR(1024) COMMENT '跳转 | PayInfo.schema',
  `friendly_tips` TEXT COMMENT '友好提示 | PayInfo.friendlyTips',
  `continuous_seat` TINYINT(1) COMMENT '连座 | PayInfo.continuousSeat',
  `count` INT COMMENT '数量 | PayInfo.count',
  `product_id` VARCHAR(128) COMMENT '商品ID | PayInfo.productId',
  `product_name` VARCHAR(512) COMMENT '商品名 | PayInfo.productName',
  `type` INT COMMENT '类型 | PayInfo.type',
  `client_type` INT COMMENT '客户端类型 | PayInfo.clientType',
  `fail_page` VARCHAR(1024) COMMENT '失败跳转 | PayInfo.failPage',
  `success_page` VARCHAR(1024) COMMENT '成功跳转 | PayInfo.successPage',
  `desc` TEXT COMMENT '描述 | PayInfo.desc',
  `detail_info` JSON COMMENT '费用明细（原 List<DetailInfo>）| PayInfo.detailInfo',
  `pay_unified_order_info` JSON COMMENT '统一订单信息 | PayInfo.payUnifiedOrderInfo',
  `tip` JSON COMMENT '提示（原 Tip）| PayInfo.tip',
  `pay_return_page` JSON COMMENT '返回页（原 PayReturnPage）| PayInfo.payReturnPage',
  `channels` JSON COMMENT '渠道列表（原 List<Channel>）| PayInfo.channels',
  `credit_pay` JSON COMMENT '信用付 | PayInfo.creditPay',
  `huabei_installment` JSON COMMENT '花呗分期（原 List<CommonInstallment>）| PayInfo.huabeiInstallment',
  `leka_installment` JSON COMMENT '乐卡分期 | PayInfo.lekaInstallment',
  `pay_after_use_info` JSON COMMENT '先用后付 | PayInfo.payAfterUseInfo',
  `payment_tips` JSON COMMENT '支付提示（原 Map<String,String>）| OrderPaymentInfo.paymentTips',
  `payment_types` JSON COMMENT '支付方式（原 List<Integer>）| OrderPaymentInfo.paymentTypes',
  `add_time` BIGINT COMMENT '创建时间 | 推断',
  PRIMARY KEY (`pay_id`),
  KEY `idx_pay_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付单 / 支付明细 | PayInfo（GET v1/unifiedPay/payDetail）· OrderPaymentInfo';

CREATE TABLE IF NOT EXISTS `payment_channels` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `pay_id` BIGINT COMMENT '支付单ID | 推断',
  `type` INT COMMENT '渠道码 | Channel.type',
  `title` VARCHAR(256) COMMENT '标题 | Channel.title',
  `value` VARCHAR(256) COMMENT '值 | Channel.value',
  `tip` VARCHAR(1024) COMMENT '提示 | Channel.tip',
  `desc` TEXT COMMENT '描述 | Channel.desc',
  `available` TINYINT(1) COMMENT '是否可用 | Flutter PayChannelOption.available',
  `client_type` INT COMMENT '客户端类型 | 推断',
  `installment_num` INT COMMENT '分期数 | CommonInstallment.installmentNum',
  `installment_rate` DECIMAL(10,4) COMMENT '分期费率 | CommonInstallment.installmentRate',
  `is_select` TINYINT(1) COMMENT '是否选中 | CommonInstallment.isSelect',
  PRIMARY KEY (`id`),
  KEY `idx_paych_pay` (`pay_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付渠道 | Channel / PayChannelOption / CommonInstallment';

CREATE TABLE IF NOT EXISTS `refunds` (
  `refund_id` BIGINT NOT NULL COMMENT '退款单ID | 推断',
  `order_id` BIGINT COMMENT '订单ID | PUT v1/order/{orderId}/refund',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `refund_amount` DECIMAL(12,2) COMMENT '退款金额 | Flutter RefundState.refundAmount',
  `reason_code` VARCHAR(64) COMMENT '退款原因码（notNeeded / boughtWrong / tooExpensive / foundBetter / other）| Flutter RefundReason',
  `custom_reason` TEXT COMMENT '自定义原因 | Flutter RefundState.customReason',
  `status` VARCHAR(64) COMMENT '退款状态 | Flutter RefundStatus',
  `error_message` VARCHAR(1024) COMMENT '错误信息 | Flutter RefundState.errorMessage',
  `refund_mode` VARCHAR(64) COMMENT '退款手续费模式（见 dict_enums.RefundRuleMode）| ActivityRefundRuleDetailBean.refundMode',
  `apply_time` BIGINT COMMENT '申请时间 | 推断',
  `update_time` BIGINT COMMENT '更新时间 | 推断',
  PRIMARY KEY (`refund_id`),
  KEY `idx_refund_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款申请 | v1/order/{orderId}/refund + Flutter RefundState / RefundReason';

-- ----------------------------------------------------------------------
--  域 5 · 营销资产（marketing）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `wallet_accounts` (
  `account_id` BIGINT NOT NULL COMMENT '账户ID | 推断',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `balance` DECIMAL(12,2) COMMENT '余额 | v1/moneyaccount / Flutter WalletAccount.balance',
  `status` INT COMMENT '状态 | 推断',
  `add_time` BIGINT COMMENT '创建时间 | 推断',
  `update_time` BIGINT COMMENT '更新时间 | 推断',
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uk_wallet_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包账户 | v1/moneyaccount + Flutter WalletAccount';

CREATE TABLE IF NOT EXISTS `wallet_sequences` (
  `id` BIGINT NOT NULL COMMENT '流水ID | Flutter WalletTransaction.id',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `account_id` BIGINT COMMENT '账户ID | 推断',
  `title` VARCHAR(512) COMMENT '标题 | Flutter WalletTransaction.title',
  `amount` DECIMAL(12,2) COMMENT '发生额（有符号）| Flutter WalletTransaction.amount',
  `balance_after` DECIMAL(12,2) COMMENT '交易后余额 | Flutter WalletTransaction.balanceAfter',
  `type` VARCHAR(64) COMMENT '收支类型（income / expense）| Flutter WalletTransactionType',
  `time` BIGINT COMMENT '发生时间 | Flutter WalletTransaction.time',
  `status` INT COMMENT '状态 | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_walletseq_user` (`user_id`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包流水 | v1/moneyaccount/sequences + Flutter WalletTransaction';

CREATE TABLE IF NOT EXISTS `gift_cards` (
  `id` BIGINT NOT NULL COMMENT '卡ID | GiftCard.id',
  `user_id` BIGINT COMMENT '持有用户 | GiftCard.userId',
  `template_id` INT COMMENT '卡模板ID | GiftCard.templateId',
  `title` VARCHAR(512) COMMENT '卡名 | GiftCard.title',
  `desc` TEXT COMMENT '说明 | GiftCard.desc',
  `denomination` DECIMAL(12,2) COMMENT '面额 | GiftCard.denomination',
  `balance` DECIMAL(12,2) COMMENT '余额 | GiftCard.balance',
  `use_amount` DECIMAL(12,2) COMMENT '本次抵扣额 | GiftCard.useAmount',
  `effective_time_from` BIGINT COMMENT '生效时间 | GiftCard.effectiveTimeFrom',
  `effective_time_to` BIGINT COMMENT '失效时间 | GiftCard.effectiveTimeTo',
  `status` INT COMMENT '状态 | GiftCard.status / Flutter GiftCardStatus',
  `type` INT COMMENT '类型 | GiftCard.type',
  `is_can_revoke` TINYINT(1) COMMENT '可撤销 | GiftCard.isCanRevoke',
  `is_disable` TINYINT(1) COMMENT '已禁用 | GiftCard.isDisable',
  `serial_number` VARCHAR(128) COMMENT '卡号（Flutter 补充）| Flutter GiftCard.serialNumber',
  `add_time` BIGINT COMMENT '创建时间 | GiftCard.addTime',
  `update_time` BIGINT COMMENT '更新时间 | GiftCard.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_gift_user` (`user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='礼品卡 | GiftCard（v1/giftCards · v2/giftCards · v3/order/allGiftCard）+ Flutter GiftCard';

CREATE TABLE IF NOT EXISTS `gift_card_usages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `order_id` BIGINT COMMENT '订单ID | 推断',
  `gift_card_id` BIGINT COMMENT '卡ID | GiftCard.id',
  `use_amount` DECIMAL(12,2) COMMENT '抵扣额 | GiftCard.useAmount',
  PRIMARY KEY (`id`),
  KEY `idx_gcu_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单礼品卡抵扣明细 | MakeOrderRequestBody.giftCards';
