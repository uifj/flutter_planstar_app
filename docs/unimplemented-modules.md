# 未实现模块清单

> **时点**：2026-11-05  
> **项目快照**：24 个路由页 / 156 个 lib dart 文件 / 31,831 行（lib 25,061 + core 6,770）  
> **静态检查**：`flutter analyze` 零 issue / `flutter test` 130 个全通过  
> **Android 对照**：约 210 个界面单元（132 Activity + 95 Fragment，去 base 后），当前覆盖约 11%

本文档逐模块列出 Android 原项目有、Flutter 侧尚未实现的页面与功能，
并标注**未实现的原因**和**实现建议**，供后续迭代参考。

---

## 0. 已实现模块速览（24 页）

| # | 路由 | 页面文件 | 对应 Android | 完成度 |
|---|------|---------|-------------|-------|
| 1 | `/splash` | `app/splash_page.dart` | `SplashActivity` + `PrivacyActivity` | 完成（隐私门 + 品牌闪屏 2s） |
| 2 | `/` | `home/home_page.dart` | `MainActivity` + `HomeFragment` | 部分（7/11 楼层，缺运营配置型楼层） |
| 3 | `/discover` | `discover/discover_page.dart` | `DiscoveryFragment` | 部分（热门/关注 + 发布，缺话题/视频） |
| 4 | `/message` | `message/message_page.dart` | `ChatListActivity` | 部分（会话列表 + 三角色卡，缺 IM 长连接） |
| 5 | `/order` | `order/order_list_page.dart` | `MyOrderActivity` | 部分（演出 Tab，缺商品 Tab / 待评论 Tab） |
| 6 | `/me` | `user/user_page.dart` | `UserFragment` | 部分（资料/订单/资产/菜单卡，缺想看卡） |
| 7 | `/login` | `auth/login_page.dart` | `LoginActivity` | **高**（已接真实接口，验证码/密码/图形验证码） |
| 8 | `/show/:showId` | `goods/show_detail_page.dart` | `ShowDetailActivity` | 部分（详情本体完成，缺选座/代抢/拼团/评价） |
| 9 | `/show/:showId/choose-ticket` | `goods/choose_ticket_page.dart` | `ChooseSkuActivity` + `SelectTicketNormalActivity` | 部分（场次/票档/数量选择，缺选座） |
| 10 | `/venue/:name` | `goods/venue_page.dart` | `VenueDetailActivity` | 部分（场馆信息 + 近期演出，缺地图） |
| 11 | `/category/:categoryId` | `catalog/ui/category_home_page.dart` | `CategoryHomeActivity` | 完成（分类 Tab + 子标签筛选 + 演出列表） |
| 12 | `/shows` | `catalog/ui/show_list_page.dart` | `HotListActivity` | 完成（排序 + 分类 Tab + 空态） |
| 13 | `/search` | `search/search_page.dart` | `SearchActivity` | 完成（历史/热搜/联想三态） |
| 14 | `/search/result` | `search/search_result_page.dart` | `SearchResultActivity` | 完成（分域结果：演出/动态） |
| 15 | `/feed/:id` | `discover/feed_detail_page.dart` | `FeedDetailActivity` | 部分（正文/评论/互动条，缺视频播放/评论发布） |
| 16 | `/message/thread/:id` | `message/chat_page.dart` | `UserMsgDetailActivity` | 部分（气泡列表 + 输入栏，无 IM 通道） |
| 17 | `/order/confirm` | `order/order_confirm_page.dart` | `OrderConfirmActivity` | **高**（优惠券/观演人/限购/金额试算/提交） |
| 18 | `/order/detail` | `order/order_detail_page.dart` | `OrderDetailWebActivity` | 部分（7 种状态 + 动作栏，缺退款/物流） |
| 19 | `/order/pay-success` | `order/pay_success_page.dart` | `PaySuccessActivity` | 完成（结果页 + 订单摘要 + 继续浏览） |
| 20 | `/settings` | `user/settings_page.dart` | `MoreSettingActivity` | 部分（深色模式/退出/意见反馈，其余 toast 占位） |
| 21 | `/address` | `user/address_page.dart` | `AddressListActivity` + `AddAddressActivity` | 完成（列表/新增/编辑/删除/设默认） |
| 22 | `/cities` | `home/city_list_page.dart` | `CityListActivity` | 部分（热门/全部城市，缺 A-Z 索引/定位） |
| 23 | `/me/edit-profile` | `user/edit_profile_page.dart` | `EditProfileActivity` | 部分（昵称/性别/简介，toast 占位提交） |
| 24 | `/feedback` | `user/feedback_page.dart` | `FeedbackActivity` | 完成（分类/内容/联系方式，toast 占位提交） |

---

## 1. 未实现模块总表

| 模块 | Android 界面数 | 缺失代表页面 | 未实现原因 | 建议优先级 |
|------|-------------|-----------|---------|----------|
| ~~支付~~ | ~~3~~ | ~~`PayActivity`~~ | ~~已实现（pay_page.dart，模拟 SDK 调用）~~ | ~~P0~~ ✅ |
| ~~选座~~ | ~~5~~ | ~~`SelectTicketSeatMapActivity`~~ | ~~已实现（seat_selection_page.dart，CustomPainter 渲染）~~ | ~~P0~~ ✅ |
| ~~优惠券 / 红包~~ | ~~3~~ | ~~`CouponActivity` / `ExchangeCouponActivity`~~ | ~~已实现（coupon_page.dart + exchange_coupon_page.dart，三 Tab + 兑换码）~~ | ~~P1~~ ✅ |
| ~~礼品卡~~ | ~~2~~ | ~~`GiftCardActivity` / `AddGiftCardActivity`~~ | ~~已实现（gift_card_page.dart + add_gift_card_page.dart，面值色块 + 绑定）~~ | ~~P1~~ ✅ |
| ~~钱包~~ | ~~1~~ | ~~`MyWalletActivity`~~ | ~~已实现（wallet_page.dart，余额 + 交易记录）~~ | ~~P1~~ ✅ |
| ~~退款~~ | ~~2~~ | ~~`OrderRefundWebActivity`~~ | ~~已实现（refund_page.dart，原生退款表单）~~ | ~~P1~~ ✅ |
| ~~代抢~~ | ~~2~~ | ~~`ProxyBuyChooseTicketActivity` / `ProxyBuyConfirmActivity`~~ | ~~已实现（proxy_buy_page.dart，规则 + 截止选项 + 订单列表）~~ | ~~P1~~ ✅ |
| ~~拼团~~ | ~~3~~ | ~~`PinTuanChooseTicketPurchaseFragment` / `PinTuanOrderListActivity`~~ | ~~已实现（group_buy_page.dart + group_buy_detail_page.dart，进度条 + 成员头像 + 参团）~~ | ~~P1~~ ✅ |
| 评论 / 评价 | 4 | `ReviewCreateActivity` / `ReviewListActivity` / `ReviewMyListActivity` / `OrderCommentActivity` | 需评论服务 + 图片上传 | P2 |
| 话题 | 5 | `TopicDetailActivity` / `TopicHotActivity` / `TopicMineActivity` / `TopicSearchActivity` / `TagFeedListActivity` | 需话题数据源 | P2 |
| 视频播放 | 4 | `VideoPlayerActivity` / `ImmersiveVideoActivity` / `VideoDetailActivity` / `FeaturedVideosActivity` | 需 CDN + 播放器内核 | P2 |
| 视频录制 | 4 | `VideoRecorderActivity` / `RecorderMainActivity` / `VideoRecorderCropActivity` / `VideoRecorderEditActivity` / `VideoRecorderSendActivity` | 需相机权限 + 裁剪 SDK | P2 |
| 文章 | 2 | `ArticleDetailActivity` / `ArticleCreateActivity` | 需文章服务接口 | P2 |
| 社区详情 | 3 | `CommunityDetailActivity` / `FollowedCommunityActivity` / `RelatedCommunitySearchActivity` | 需社区数据源 | P2 |
| 分享 | 4 | `ShareBottomActivity` / `SharePictureActivity` / `SharePsPictureActivity` / `ShareActivity` | 需 fluwx / 系统分享 | P2 |
| WebView / JsBridge | 3 | `WebActivity` / `JsBridgeActivity` / `PsWxMiniProgramActivity` | 需 webview_flutter + JS 桥协议 | P3 |
| 演员 / 阵容 | 5 | `ActorDetailActivity` / `ActorFollowingActivity` / `ActorSearchActivity` / `LineupListActivity` / `MineFollowedActivity` | 需演员数据源 | P3 |
| 图集 / 相册 | 3 | `GalleryActivity` / `GalleryDetailActivity` / `PreviewPhotoActivity` | 需图片浏览组件 | P3 |
| 日历 | 1 | `CalendarShowActivity` | 需日历数据源 | P3 |
| 商城 | 4 | `MallHomeFragment` / `GoodsDetailActivity` / `GoodsOrderDetailActivity` / 商品订单 Tab | 需独立商品域聚合 | P3 |
| 关于 / 协议 | 3 | `AboutActivity` / `AgreementRuleActivity` / `PrivacyActivity`（隐私政策页） | 需 WebView 或静态页 | P3 |
| 账号安全 | 7 | `EditPasswordActivity` / `BindPhoneActivity` / `ForgetActivity` / `ResetActivity` / `QuickLoginActivity` / `UnregisterAccountActivity` / `BusinessCooperationActivity` | 需账号安全服务 | P3 |
| 实名认证 | 2 | `IdListActivity` / `AddIdActivity` | 需 id 聚合服务 | P3 |
| 个人主页 | 2 | `UserHomeActivity` / `UserAvatarHomeActivity` | 需用户公开资料接口 | P3 |
| 推荐 / 关联 | 4 | `RecommendActivity` / `RelatedActivitySearchActivity` / `RelatedTagSearchActivity` / `HomeFloorRecommendListActivity` | 运营配置型，需后端 schema | P3 |
| 通用 / 调试 | 4 | `PopboxActivity` / `AppLinkActivity` / `BrowseModeListActivity` / `DebugActivity` | 壳层 / 调试工具 | P3 |

**合计**：约 86 个界面单元尚未实现（不含 base / 调试类）。

---

## 2. 逐模块详细说明

### 2.1 支付（P0）

**Android 对应**：`PayActivity` / `CmbPayWebActivity` / `WXPayEntryActivity` / `AbcPayEntryActivity`

**现状**：Flutter 侧有 `PaySuccessPage`（支付成功后的结果页），但**支付动作本身**没有实现。`OrderConfirmPage` 提交订单后直接跳到 `/order/pay-success`，跳过了支付环节。

**缺失内容**：
- 支付方式选择面板（微信 / 支付宝 / 银联 / 招行 H5）
- 微信支付 SDK 集成（`fluwx` 包）
- 支付宝 SDK 集成（`tobias` 包）
- 招商银行 H5 支付页（`CmbPayWebActivity` → WebView）
- 支付结果回调处理（`WXPayEntryActivity` 等价物）
- 支付超时 / 取消 / 失败的状态机

**实现建议**：
- 引入 `fluwx`（微信）和 `tobias`（支付宝）包
- 支付方式选择复用 `_PaymentChannelSheet`（已在 `order_list_page.dart` 中作为公共组件提取）
- 支付前先调 `v1/order/createPayment` 拿到 prepay 参数，再调 SDK
- 招行 H5 用 `webview_flutter` 打开

---

### 2.2 选座（P0）

**Android 对应**：`SelectTicketSeatMapActivity` / `SelectTicketNormalActivity` / `ChooseTicketSeatMapFragment` / `ChooseTicketSeatTableFragment` / `SelectTicketBaseActivity`

**现状**：`ChooseTicketPage` 只实现了**普通购票**（选场次 → 选票档 → 选数量），没有座位图选择。企划星的演出中有大量需要选座的场次（音乐会、话剧等），这是购票链路的核心缺口。

**缺失内容**：
- 座位图数据结构（区域 → 排 → 座位三级模型）
- 缩放 / 拖拽手势（`InteractiveViewer` + 自定义 `GestureDetector`）
- 座位状态渲染（可选 / 已选 / 已售 / 锁定 / 通道）
- 区域切换（大图 → 小图 → 排座详情）
- 锁座与超时（选座后 15 分钟内未下单自动释放）
- 与订单草稿的联动（选好的座位传入确认页）

**实现建议**：
- **单独立项**——这不是"再画一个页面"，而是一条完整的数据 + 交互链路
- 座位图用 `CustomPainter` 绘制（性能优于嵌套 Widget）
- 数据结构参考 Android `SeatMap` / `SeatArea` / `SeatRow` / `Seat`
- 建议先做"区域-排-座"三级选中模型的纯逻辑层，再用 Widget 渲染

---

### 2.3 优惠券 / 红包（P1）

**Android 对应**：`CouponActivity` / `CouponShowActivity` / `ExchangeCouponActivity` / `DiscountListActivity`

**现状**：`OrderConfirmPage` 的金额试算逻辑中预留了优惠券字段，但没有独立的券列表页 / 券选择页 / 兑换码输入页。

**缺失内容**：
- 我的优惠券列表（未使用 / 已使用 / 已过期三 Tab）
- 下单时选择优惠券（可用券筛选 + 互斥规则）
- 兑换码输入页（`ExchangeCouponActivity`）
- 券详情页（使用规则 / 适用范围 / 有效期）
- 首页"领券中心"入口（`CouponShowActivity`）

**实现建议**：
- 新建 `lib/features/marketing/` 模块
- DTO 对齐 `v1/coupon/list` + `v1/coupon/exchange` + `v1/coupon/available`
- 列表页复用 `PsCell` / `PsTag` / `PsEmptyState`
- 券选择 sheet 复用 `_PaymentChannelSheet` 的模式

---

### 2.4 礼品卡（P1）

**Android 对应**：`GiftCardActivity` / `AddGiftCardActivity`

**现状**：完全未实现。`OrderConfirmPage` 预留了礼品卡字段但无入口。

**缺失内容**：
- 礼品卡列表（余额 / 有效期 / 使用范围）
- 添加礼品卡（卡号 + 密码输入）
- 礼品卡使用记录

**实现建议**：
- 与优惠券同属 `marketing` 模块
- DTO 对齐 `v1/giftcard/list` + `v1/giftcard/bind`

---

### 2.5 钱包（P1）

**Android 对应**：`MyWalletActivity`

**现状**：`UserPage` 的资产卡有钱包余额显示位，但值为演示常量（`¥128.50`）。

**缺失内容**：
- 钱包主页（余额 / 明细 / 充值 / 提现）
- 收支明细列表
- 充值 / 提现流程

**实现建议**：
- DTO 对齐 `v1/wallet/balance` + `v1/wallet/transactions`
- 充值走支付流程（复用支付 SDK）
- 提现需要绑定银行卡（不在当前范围）

---

### 2.6 退款（P1）

**Android 对应**：`OrderRefundWebActivity` + 退款申请页

**现状**：`OrderDetailPage` 的动作栏没有"申请退款"按钮。

**缺失内容**：
- 退款申请页（退款原因 / 退款金额 / 退款方式）
- 退款进度查询
- 退款结果通知

**实现建议**：
- 退款原因用 `PsCell` 单选列表
- 退款金额自动计算（已出票 / 未出票规则不同）
- 退款流程走 WebView（企划星原项目也是 H5）

---

### 2.7 代抢 / 拼团 / 求票（P1）

**Android 对应**：`ProxyBuyChooseTicketActivity` / `ProxyBuyConfirmActivity` / `PinTuanChooseTicketPurchaseFragment` / `PinTuanOrderListActivity`

**现状**：`package:core/domain.dart` 的 `OrderType` 枚举已包含 `proxyBuy` / `groupBuy`，但没有对应的链路页面。`ShowDetailPage` 的注释明确写了"只做了普通购票"。

**缺失内容**：
- 代抢购票：选票档 → 填代抢信息 → 确认 → 支付（与普通购票流程类似但有代抢标记）
- 拼团购票：开团 / 参团 → 选票 → 确认 → 支付 → 分享拉人
- 求票浮球：详情页右侧悬浮入口 → 填求票信息
- 拼团订单列表：我的拼团（进行中 / 成功 / 失败）

**实现建议**：
- 代抢：复用 `ChooseTicketPage` + `OrderConfirmPage`，追加代抢信息表单
- 拼团：需要拼团活动数据源 + 倒计时 + 分享拉人流程
- 求票：详情页加浮球入口 + 求票信息表单

---

### 2.8 评论 / 评价（P2）

**Android 对应**：`ReviewCreateActivity` / `ReviewListActivity` / `ReviewMyListActivity` / `OrderCommentActivity`

**现状**：`FeedDetailPage` 的评论区是只读的（toast 说明"评论发布待接入"）。演出详情页没有评价区。订单完成后"去评价"按钮跳到的页面不存在。

**缺失内容**：
- 写评价页（评分 / 文字 / 图片上传 / 匿名）
- 评价列表页（演出评价列表 + 排序 + 有用）
- 我的评价页（已写 / 待写）
- 订单评价入口（`OrderCommentActivity`）

**实现建议**：
- 新建 `lib/features/review/` 模块
- 评分用 5 星组件（自绘）
- 图片上传走 `package:core/upload.dart`（已有 `ImageUploader` 端口）
- DTO 对齐 `v1/review/create` + `v1/review/list`

---

### 2.9 话题（P2）

**Android 对应**：`TopicDetailActivity` / `TopicHotActivity` / `TopicMineActivity` / `TopicSearchActivity` / `TagFeedListActivity`

**现状**：`DiscoverPage` 没有话题入口。

**缺失内容**：
- 话题详情页（话题描述 + 动态列表 + 参与按钮）
- 热门话题列表
- 我的话题
- 话题搜索
- 标签下的动态列表

**实现建议**：
- 新建 `lib/features/topic/` 模块
- 动态列表复用 `FeedCard`（已在 `discover/widgets/` 中）
- 话题参与 = 发布动态时绑定话题 ID

---

### 2.10 视频播放（P2）

**Android 对应**：`VideoPlayerActivity` / `ImmersiveVideoActivity` / `VideoDetailActivity` / `FeaturedVideosActivity`

**现状**：`FeedDetailPage` 的 `hasVideo` 为真时只显示一个"播放器尚未接入"的说明条。完全没有视频播放能力。

**缺失内容**：
- 视频播放器内核（ExoPlayer 等价物）
- 沉浸式视频流（上下滑动切换）
- 视频详情页（视频 + 信息 + 评论）
- 精选视频列表

**未实现原因**：播放器需要 CDN 配置、缓冲策略、codec 适配，不是画一个 UI 就能用的。

**实现建议**：
- 使用 `video_player` 包（官方）或 `chewie`（带 UI）
- 沉浸式流用 `PageView` + `video_player`
- 需要独立的 CDN 域名配置（`api_config.dart` 中预留）

---

### 2.11 视频录制（P2）

**Android 对应**：`VideoRecorderActivity` / `RecorderMainActivity` / `VideoRecorderCropActivity` / `VideoRecorderEditActivity` / `VideoRecorderSendActivity`

**现状**：`DiscoverPage` 的发布按钮只支持图文动态，不支持视频。

**缺失内容**：
- 视频录制（相机权限 + 预览 + 录制）
- 视频裁剪
- 视频编辑（滤镜 / 配乐 / 贴纸）
- 视频发送（上传 + 发布）

**实现建议**：
- 相机层用 `camera` 包
- 裁剪 / 编辑需要专门的 SDK（参考 Android 的 `VideoRecorderCropActivity`）
- 上传走 `package:core/upload.dart`

---

### 2.12 文章（P2）

**Android 对应**：`ArticleDetailActivity` / `ArticleCreateActivity` / `ArticleListActivity`

**现状**：`FeedDetailPage` 只支持图文动态，不支持长文章。

**缺失内容**：
- 文章详情页（富文本渲染 + 封面图 + 作者信息）
- 文章创建页（富文本编辑器 + 封面上传）
- 文章列表

**实现建议**：
- 富文本渲染用 `flutter_html` 或 `flutter_widget_from_html`
- 文章数据源需独立 DTO（`v1/article/detail`）

---

### 2.13 社区详情（P2）

**Android 对应**：`CommunityDetailActivity` / `FollowedCommunityActivity` / `RelatedCommunitySearchActivity`

**现状**：`DiscoverPage` 没有社区概念。

**缺失内容**：
- 社区详情页（社区简介 + 成员 + 动态列表）
- 已关注社区列表
- 关联社区搜索

**实现建议**：
- 与话题模块同源，可合并到 `topic` 或独立 `community` 模块

---

### 2.14 分享（P2）

**Android 对应**：`ShareBottomActivity` / `SharePictureActivity` / `SharePsPictureActivity` / `ShareActivity`

**现状**：所有页面的分享按钮都是 toast（"分享面板待接入 fluwx"）。

**缺失内容**：
- 底部分享面板（微信好友 / 朋友圈 / QQ / 微博 / 复制链接 / 生成图片）
- 生成分享图片（演出海报 + 二维码）
- 分享到微信小程序

**实现建议**：
- 引入 `fluwx`（微信分享）
- 分享图片生成用 `RepaintBoundary` + `toImage`
- 底部面板用 `showModalBottomSheet`（复用 `_PaymentChannelSheet` 模式）

---

### 2.15 WebView / JsBridge（P3）

**Android 对应**：`WebActivity` / `JsBridgeActivity` / `PsWxMiniProgramActivity`

**现状**：设置页的"用户协议""隐私政策"是 toast，没有 WebView 页面。

**缺失内容**：
- 通用 WebView 页（加载 URL + 标题 + 进度条 + 返回）
- JSBridge（原生 ↔ H5 通信协议）
- 微信小程序容器（`PsWxMiniProgramActivity`）

**实现建议**：
- 引入 `webview_flutter`
- JSBridge 参考 Android 的 `JsBridgeActivity` 协议（`pn://` scheme）
- 协议页 / 隐私政策 / 招行支付 / 退款流程都需要 WebView

---

### 2.16 演员 / 阵容（P3）

**Android 对应**：`ActorDetailActivity` / `ActorFollowingActivity` / `ActorSearchActivity` / `LineupListActivity` / `MineFollowedActivity`

**现状**：`ShowDetailPage` 的阵容区只显示名字列表，点击无跳转。

**缺失内容**：
- 演员详情页（头像 / 简介 / 代表作品 / 关注按钮）
- 演员关注列表
- 演员搜索
- 阵容列表（演出的全部演员）
- 我关注的演员

**实现建议**：
- 新建 `lib/features/actor/` 模块
- DTO 对齐 `v1/actor/detail` + `v1/actor/follow`
- 演员详情页结构类似 `VenuePage`

---

### 2.17 图集 / 相册（P3）

**Android 对应**：`GalleryActivity` / `GalleryDetailActivity` / `PreviewPhotoActivity`

**现状**：`ShowDetailPage` 的头部海报是单张，没有图集浏览。

**缺失内容**：
- 演出图集（多张宣传图滑动浏览）
- 全屏图片预览（双指缩放 / 左右切换）
- 图片下载

**实现建议**：
- 使用 `photo_view` 包实现缩放
- 图集用 `PageView`

---

### 2.18 日历（P3）

**Android 对应**：`CalendarShowActivity`

**现状**：首页没有日历入口。

**缺失内容**：
- 演出日历（按日期显示当天有演出的场次）
- 日历筛选（城市 / 分类）

**实现建议**：
- 使用 `table_calendar` 包
- 数据来自 `catalog` 域（按日期过滤演出）

---

### 2.19 商城（P3）

**Android 对应**：`MallHomeFragment` / `GoodsDetailActivity` / `GoodsOrderDetailActivity`

**现状**：订单列表的"商品"Tab 是显式空状态。

**缺失内容**：
- 商城首页
- 商品详情页
- 商品订单详情
- 购物车 / 下单流程

**实现建议**：
- 独立的商品域聚合（与票务平行）
- **不建议短期实现**——商城是独立业务线，当前应聚焦票务链路

---

### 2.20 关于 / 协议页（P3）

**Android 对应**：`AboutActivity` / `AgreementRuleActivity` / `PrivacyActivity`

**现状**：设置页的"用户协议""隐私政策"是 toast。没有关于页。

**缺失内容**：
- 关于页（版本号 / 官网 / 联系方式 / ICP 备案号）
- 用户协议页（WebView 或静态文本）
- 隐私政策页（WebView 或静态文本）

**实现建议**：
- 关于页用静态 Widget
- 协议页用 WebView（依赖 §2.15）或 `flutter_html` 渲染本地 HTML

---

### 2.21 账号安全（P3）

**Android 对应**：`EditPasswordActivity` / `BindPhoneActivity` / `ForgetActivity` / `ResetActivity` / `QuickLoginActivity` / `UnregisterAccountActivity` / `BusinessCooperationActivity`

**现状**：设置页的"手机号"是 toast（"换绑手机号需要先验证原手机号"）。

**缺失内容**：
- 修改密码
- 换绑手机号（验证原手机 → 输入新手机 → 验证码）
- 忘记密码（手机号 → 验证码 → 重置）
- 快速登录（本机号码一键登录，需运营商 SDK）
- 注销账号
- 商务合作

**实现建议**：
- 换绑 / 忘记密码复用 `LoginPage` 的验证码流程
- 快速登录需 `运营商一键登录` SDK（中国移动 / 联通 / 电信）
- 注销走 WebView 或独立流程

---

### 2.22 实名认证（P3）

**Android 对应**：`IdListActivity` / `AddIdActivity`

**现状**：设置页的"实名认证"是 toast（"属于独立的 id 聚合，本示例未实现"）。

**缺失内容**：
- 实名认证列表（已认证的证件列表）
- 添加证件（姓名 + 证件类型 + 证件号 + 人脸识别）

**实现建议**：
- 人脸识别需第三方 SDK（旷视 / 商汤）
- **不建议短期实现**——合规要求高，SDK 依赖重

---

### 2.23 个人主页（P3）

**Android 对应**：`UserHomeActivity` / `UserAvatarHomeActivity`

**现状**：`UserPage` 是"我的"（自己看自己），没有"别人的主页"。

**缺失内容**：
- 用户公开主页（头像 / 昵称 / 简介 / 动态 / 关注 / 粉丝）
- 头像主页（点击头像看大图 + 动态）

**实现建议**：
- DTO 对齐 `v1/user/home`
- 动态列表复用 `FeedCard`

---

### 2.24 推荐 / 关联（P3）

**Android 对应**：`RecommendActivity` / `RelatedActivitySearchActivity` / `RelatedTagSearchActivity` / `HomeFloorRecommendListActivity` / `DesignationShowListActivity`

**现状**：首页"推荐"楼层没有独立列表页。

**缺失内容**：
- 推荐演出列表（首页楼层"查看更多"）
- 关联演出搜索（演员 / 场馆 / 标签的关联演出）
- 标签搜索结果

**实现建议**：
- 复用 `ShowListPage`（已支持分类 + 排序）
- 标签 / 关联只是 filter 参数不同

---

### 2.25 首页缺失楼层（P3）

**Android 对应**：`OpProvider` / `CenterOpProvider` / `ThemeRecommendProvider` / `HomeWaterfallProvider` / `ActorsProvider` / `RecommendWordProvider` / `HomeHotTourProvider` / `HomeHotActorSiteProvider` / `HomeRecommendProvider`

**现状**：首页实现了 7/11 个楼层，缺以下 4 类：

| 缺失楼层 | Android 作用 | 未实现原因 |
|---------|-----------|---------|
| 运营位（`OpProvider`） | 服务端下发 `ViewType` + `schema` 拼装 | 无接口 → 无固定布局 → 硬造会得到"永远不对"的占位 |
| 瀑布流（`HomeWaterfallProvider`） | 异形卡瀑布流推荐 | 同上 |
| 明星 / 演员推荐（`ActorsProvider` / `HomeHotActorSiteProvider`） | 热门演员/场地推荐 | 无演员数据源 |
| 推荐词（`RecommendWordProvider`） | 搜索推荐词楼层 | 无推荐词接口 |

**实现建议**：
- 这些楼层是**服务端配置型**，没有接口就无法对齐
- 后端接线后按 `ViewType` 分发到不同的 Widget 渲染

---

### 2.26 首页缺失二级页（P3）

**Android 对应**：`HomeFloorRecommendListActivity` / `HomeHotTourListActivity` / `CalendarShowActivity`

**现状**：首页楼层没有"查看更多"跳转。

**缺失内容**：
- 楼层推荐列表（`HomeFloorRecommendListActivity`）
- 热门巡演列表（`HomeHotTourListActivity`）
- 日历演出列表（`CalendarShowActivity`）

**实现建议**：
- 复用 `ShowListPage` + 不同 filter 参数

---

### 2.27 系统性缺口（跨模块）

| 缺口 | 影响范围 | 说明 |
|------|--------|------|
| **后端接线** | 全部模块 | 只有 `auth` 域走真网络，其余 7 个域全是内存假数据。补 20 个页面仍然只能读假数据。 |
| **图片资源** | 全部页面 | 138 张图里没有海报 / 分类图标。海报走 `PsPoster` 渐变占位。 |
| **文案 l10n** | 全部页面 | 除登录页外，中文是字面量，ARB 只有标题类 key。 |
| **A/B 测试 / 埋点** | 全部页面 | Android 有完整埋点体系（`Statistics` / `TrackEvent`），Flutter 侧无。 |
| **推送** | 消息 / 订单 | Android 用 JPush，Flutter 侧无推送能力。 |
| **IM 长连接** | 消息 | Android 用环信 IM，Flutter 侧 `ChatPage` 只有本地消息。 |
| **地图 / 定位** | 场馆 / 城市 | Android 用高德地图，Flutter 侧无地图 SDK。 |
| **资源流水线** | 全部页面 | 2,387 个 drawable 里的 `.9.png` / `selector` / `shape` / `vector` 没有等价物。 |

---

## 3. 建议推进顺序

按「一条链路打穿」而非「一个模块均匀铺开」排——前者能验证架构，后者只会摊薄。

| 期 | 目标 | 涉及模块 | 完成标志 |
|----|------|--------|--------|
| **P0** | 购票主链路接通 | 支付 → 选座 | 一条真实订单能选座 → 下单 → 支付 → 查看详情 |
| **P1** | 补齐交易分支 | 优惠券 / 礼品卡 / 钱包 / 退款 / 代抢 / 拼团 | 交易域 8 个界面补齐 |
| **P2** | 内容与社交 | 评论 / 话题 / 视频 / 文章 / 社区 / 分享 | `discovery` + `feed` + `video` 核心界面 |
| **P3** | 长尾收尾 | WebView / 演员 / 图集 / 日历 / 商城 / 关于 / 账号安全 / 实名 / 个人主页 / 推荐 | 剩余约 40 个界面 |

---

## 4. 相关文档

- [page-parity.md](page-parity.md) — 已实现页面的逐页对照说明
- [api-contract.md](api-contract.md) — 后端接口契约（登录域已接通）
- [ddd-order-domain.md](ddd-order-domain.md) — 订单领域模型设计
- `wiki_zh/31-flutter-parity-gap.md` — 18 路由时点的完整差距分析（历史快照）
