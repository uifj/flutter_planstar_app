-- ========================================================================
--  02 · 用户与账号
--  服务库: planstar_user
--  执行顺序: 01_init_databases.sql → 02 … 09 → 10 / 11 → 12_constraints.sql
--  本文件 9 张表: users, login_sessions, real_name_infos, user_addresses, user_follows, user_statistics, user_messages, chat_threads, chat_messages
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/tree/main/sql
--    NN_<域>.sql 按服务分库 + migrations/<库>/000001_init.up.sql / .down.sql
--  方言: MySQL 8.0 / InnoDB / utf8mb4（按用户选择保持，未切换 PostgreSQL）
--  第三方 SDK 表（小米推送 / 极光 JPush / 百度定位·mshield / Bugly /
--    字节 AppLog·bdtracker）共 31 张已按要求全部移除。
-- ========================================================================

USE `planstar_user`;

-- ----------------------------------------------------------------------
--  域 1 · 账号与身份（account / identity）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `users` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID | UserBean.userId（原 Java int，逆向统一放宽）',
  `user_name` VARCHAR(128) COMMENT '用户名 | UserBean.userName',
  `avatar` VARCHAR(512) COMMENT '头像 URL | UserBean.avatar',
  `badge_icon` VARCHAR(512) COMMENT '徽章图标 | UserBean.badgeIcon',
  `bio` VARCHAR(1024) COMMENT '个人简介 | UserBean.bio',
  `birthday` BIGINT COMMENT '生日（epoch 毫秒）| UserBean.birthday',
  `gender` INT COMMENT '性别 | UserBean.gender',
  `mobile_no` VARCHAR(32) COMMENT '手机号 | UserBean.mobileNo',
  `phone` VARCHAR(32) COMMENT '手机号（UserProfile 冗余字段）| UserProfile.phone',
  `level` INT COMMENT '用户等级 | UserBean.level',
  `level_desc` VARCHAR(128) COMMENT '等级描述 | UserProfile.levelDesc',
  `score` DOUBLE COMMENT '评分 / 信用分 | UserBean.score',
  `status` INT COMMENT '账号状态 | UserBean.status',
  `shop_type` INT COMMENT '店铺类型（卖家标识）| UserBean.shopType',
  `is_douli_user` TINYINT(1) COMMENT '是否斗牛用户 | UserBean.isDouliUser',
  `blocked` TINYINT(1) COMMENT '是否被拉黑 | UserBean.blocked',
  `follow_him` INT COMMENT '我关注他（原字段名 followed）| UserBean.followed',
  `followed_by_him` INT COMMENT '他关注我 | UserBean.followedByHim',
  `follower_num` INT COMMENT '粉丝数 | UserBean.followerNum',
  `following_num` INT COMMENT '关注数（仅用户）| UserBean.followingNum',
  `force_follow` TINYINT(1) COMMENT '强制关注 | UserBean.forceFollow',
  `review_liked_num` INT COMMENT '获赞数 | UserBean.reviewLikedNum',
  `want_watch_num` INT COMMENT '想看数 | UserBean.wantWatchNum',
  `watched_num` INT COMMENT '看过数 | UserBean.watchedNum',
  `add_time` BIGINT COMMENT '创建时间（epoch 毫秒）| UserBean.addTime',
  `update_time` BIGINT COMMENT '更新时间（epoch 毫秒）| UserBean.updateTime',
  `ext` JSON COMMENT '扩展字段 | 预留',
  PRIMARY KEY (`user_id`),
  KEY `idx_users_mobile` (`mobile_no`),
  KEY `idx_users_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户主档 | Android UserBean / UserProfile / LoginBean + Flutter AuthUser';

CREATE TABLE IF NOT EXISTS `login_sessions` (
  `session_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `user_id` BIGINT COMMENT '用户ID | LoginBean.user.userId',
  `login_type` INT COMMENT '登录方式（密码 / 短信 / 三方）| v1/user/login · tpLogin',
  `access_token` VARCHAR(512) COMMENT '访问令牌 | TPLoginBean.accessToken',
  `union_id` VARCHAR(128) COMMENT '三方 UnionID | TPLoginBean.unionId',
  `is_bound` TINYINT(1) COMMENT '是否已绑定 | TPLoginBean.isBound',
  `new_user` TINYINT(1) COMMENT '是否新用户 | LoginBean.newUser',
  `need_captcha` TINYINT(1) COMMENT '是否需要图形验证码 | LoginBean.needCaptcha',
  `captcha_cooldown` INT COMMENT '验证码冷却秒数（客户端 60 秒倒计时依据）| BaseLoginActivity',
  `error_msg` VARCHAR(512) COMMENT '错误提示 | SendCodeResponseDto.errorMsg',
  `success` TINYINT(1) COMMENT '请求是否成功 | SendCodeResponseDto.success',
  `device_id` VARCHAR(128) COMMENT '设备标识 | dvid',
  `add_time` BIGINT COMMENT '登录时间 | 推断',
  `expire_time` BIGINT COMMENT '过期时间 | 推断',
  PRIMARY KEY (`session_id`),
  KEY `idx_login_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录会话 / 三方登录 / 验证码 | LoginBean / TPLoginBean / SendCodeResponseDto';

CREATE TABLE IF NOT EXISTS `real_name_infos` (
  `id` BIGINT NOT NULL COMMENT '实名信息ID | IdInfo.id',
  `user_id` BIGINT COMMENT '所属用户 | v1/user/realNameInfo/save',
  `name` VARCHAR(128) COMMENT '姓名 | IdInfo.name',
  `id_card_no` VARCHAR(64) COMMENT '证件号 | IdInfo.idCardNo / Visitor.idCard.value',
  `id_card_type` INT COMMENT '证件类型（1 身份证 / 2 护照 / 3 港澳通行证 / 4 台湾通行证 / 5 港澳台居住证）| IdCardType',
  `country_area_id` INT COMMENT '国家/地区ID | IdInfo.countryAreaId',
  `country_area_name` VARCHAR(128) COMMENT '国家/地区名 | IdInfo.countryAreaName',
  `status` INT COMMENT '状态 | 推断',
  `add_time` BIGINT COMMENT '创建时间 | 推断',
  `update_time` BIGINT COMMENT '更新时间 | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_realname_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实名信息 / 观演人 | IdInfo / IdCard / Visitor / realNameInfo';

CREATE TABLE IF NOT EXISTS `user_addresses` (
  `address_id` BIGINT NOT NULL COMMENT '地址ID | AddressBean.id',
  `user_id` BIGINT COMMENT '用户ID | AddressBean.userId',
  `name` VARCHAR(128) COMMENT '收件人 | AddressBean.name',
  `phone` VARCHAR(32) COMMENT '联系电话 | AddressBean.phone',
  `province` VARCHAR(64) COMMENT '省 | Flutter ShippingAddress.region',
  `city` VARCHAR(64) COMMENT '市 | AddressBean.district 解析',
  `district` VARCHAR(64) COMMENT '区 | AddressBean.district',
  `district_id` INT COMMENT '区县ID | AddressBean.districtId',
  `detail_address` TEXT COMMENT '详细地址 | AddressBean.address',
  `address_type` INT COMMENT '地址类型 | AddressBean.addressType',
  `is_default` TINYINT(1) COMMENT '是否默认 | AddressBean.isDefault',
  `is_recent` TINYINT(1) COMMENT '是否最近使用 | AddressBean.isRecent',
  `latest_id` BIGINT COMMENT '最近地址ID（MyAddressBean）| MyAddressBean.latestId',
  `receiver_name` VARCHAR(128) COMMENT '最近收件人 | MyAddressBean.receiverName',
  `receiver_phone` VARCHAR(32) COMMENT '最近收件电话 | MyAddressBean.receiverPhone',
  `status` INT COMMENT '状态 | AddressBean.status',
  `add_time` BIGINT COMMENT '创建时间 | AddressBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | AddressBean.updateTime',
  PRIMARY KEY (`address_id`),
  KEY `idx_addr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址 | AddressBean / MyAddressBean + Flutter ShippingAddress';

CREATE TABLE IF NOT EXISTS `user_follows` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `user_id` BIGINT COMMENT '发起人 | v1/user/follow',
  `target_type` INT COMMENT '目标类型（1 用户 / 2 艺人 / 3 群组）| 推断',
  `target_id` BIGINT COMMENT '目标ID | actorId / userId',
  `status` INT COMMENT '状态 | 推断',
  `add_time` BIGINT COMMENT '关注时间 | 推断',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_follow` (`user_id`,`target_type`,`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='关注关系（用户 / 艺人）| v1/user/follow · v1/actorFollow · following/actors · following/mine';

CREATE TABLE IF NOT EXISTS `user_statistics` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `actor_following` INT COMMENT '关注艺人数（与 following_num 相加为总关注数）| StatisticBean.actorFollowing',
  `balance` DECIMAL(12,2) COMMENT '钱包余额（元）| StatisticBean.balance',
  `coupon_num` INT COMMENT '优惠券张数 | StatisticBean.couponNum',
  `follower_num` INT COMMENT '粉丝数 | StatisticBean.followerNum',
  `following_num` INT COMMENT '关注用户数 | StatisticBean.followingNum',
  `getting_tickets_num` INT COMMENT '待收货 | StatisticBean.gettingTicketsNum',
  `gift_card_num` INT COMMENT '礼品卡张数 | StatisticBean.giftCardNum',
  `msg_num` INT COMMENT '未读消息数 | StatisticBean.msgNum',
  `paying_num` INT COMMENT '待付款 | StatisticBean.payingNum',
  `review_num` INT COMMENT '评论数 | StatisticBean.reviewNum',
  `review_todo_num` INT COMMENT '待评论 | StatisticBean.reviewTodoNum',
  `waiting_for_tickets_num` INT COMMENT '待发货 | StatisticBean.waitingForTicketsNum',
  `want_watch_num` INT COMMENT '想看数 | StatisticBean.wantWatchNum',
  `update_time` BIGINT COMMENT '统计时间 | 推断',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户中心角标统计 | StatisticBean（GET v1/user/stat）';

CREATE TABLE IF NOT EXISTS `user_messages` (
  `message_id` BIGINT NOT NULL COMMENT '消息ID | UserMessage.id',
  `user_id` BIGINT COMMENT '接收用户 | UserMessage.userId',
  `from_user_id` BIGINT COMMENT '发送用户 | UserMessage.fromUserId',
  `from_user` JSON COMMENT '发送人快照（原 UserBean）| UserMessage.fromUser',
  `title` VARCHAR(512) COMMENT '标题 | UserMessage.title',
  `content` TEXT COMMENT '正文 | UserMessage.content',
  `msg_type` INT COMMENT '消息类型（见 dict_enums.UserMsgType）| UserMessage.type',
  `status` INT COMMENT '状态 | UserMessage.status',
  `url` VARCHAR(1024) COMMENT '跳转链接 | UserMessage.url',
  `unread_count` INT COMMENT '未读数 | UserMessageSimple.unReadCount',
  `add_time` BIGINT COMMENT '创建时间 | UserMessage.addTime',
  `update_time` BIGINT COMMENT '更新时间 | UserMessage.updateTime',
  PRIMARY KEY (`message_id`),
  KEY `idx_msg_user_type` (`user_id`,`msg_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息中心 | UserMessage / UserMessageSimple / UserMsgCount / SystemMessageEntry';

CREATE TABLE IF NOT EXISTS `chat_threads` (
  `thread_id` VARCHAR(64) NOT NULL COMMENT '会话ID | Flutter MessageThread.id',
  `user_id` BIGINT COMMENT '用户ID',
  `title` VARCHAR(256) COMMENT '会话标题 | MessageThread.title',
  `preview` VARCHAR(1024) COMMENT '最后一条预览 | MessageThread.preview',
  `updated_at` BIGINT COMMENT '最后更新时间 | MessageThread.updatedAt',
  `unread_count` INT COMMENT '未读数 | MessageThread.unreadCount',
  `avatar_url` VARCHAR(512) COMMENT '头像（开源图床 URL）| MessageThread.avatarFallbackUrl',
  `is_official` TINYINT(1) COMMENT '是否官方客服 | MessageThread.isOfficial',
  `visitor_token` VARCHAR(256) COMMENT '环信 visitor token | v1/chat/visitor',
  PRIMARY KEY (`thread_id`),
  KEY `idx_thread_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客服 / 会话线程 | ChatService v1/chat/user · v1/chat/visitor + Flutter MessageThread';

CREATE TABLE IF NOT EXISTS `chat_messages` (
  `id` VARCHAR(64) NOT NULL COMMENT '消息ID | ChatMessage.id',
  `thread_id` VARCHAR(64) COMMENT '会话ID',
  `text` TEXT COMMENT '消息文本 | ChatMessage.text',
  `sent_at` BIGINT COMMENT '发送时间 | ChatMessage.sentAt',
  `from_me` TINYINT(1) COMMENT '是否自己发出 | ChatMessage.fromMe',
  `sender_name` VARCHAR(128) COMMENT '发送者名 | ChatMessage.senderName',
  PRIMARY KEY (`id`),
  KEY `idx_chatmsg_thread` (`thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会话消息 | Flutter ChatMessage';
