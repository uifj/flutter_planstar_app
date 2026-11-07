# 未实现模块清单

> 适用版本：planstar Flutter 9.9.39 · 最后核对：2026-11-07 · 维护：客户端组

> **时点**：2026-11-07 全流程回归复测  
> **项目快照**：36 个路由页 / 268 个 lib dart 文件 / 54,977 行（lib 51,488 + core 3,489）  
> **静态检查**：`flutter analyze` 零 issue / `flutter test` 202 个全通过  
> **Android 对照**：约 210 个界面单元（132 Activity + 95 Fragment，去 base 后），当前覆盖约 11%

本文档逐模块列出 Android 原项目有、Flutter 侧尚未实现的页面与功能，
并标注**未实现的原因**和**实现建议**，供后续迭代参考。

---

## 0. 已实现模块速览（36 页）

| # | 路由 | 页面文件 | 对应 Android | 完成度 |
|---|------|---------|-------------|-------|
| 1 | `/splash` | `app/splash_page.dart` | `SplashActivity` + `PrivacyActivity` | 完成（隐私门 + 品牌闪屏 2s） |
| 2 | `/` | `home/home_page.dart` | `MainActivity` + `HomeFragment` | 部分（7/11 楼层，缺运营配置型楼层） |
| 3 | `/discover` | `discover/discover_page.dart` | `DiscoveryFragment` | 部分（热门/关注 + 发布，缺话题/视频） |
| 4 | `/message` | `message/message_page.dart` | `ChatListActivity` | 部分（会话列表 + 三角色卡，缺 IM 长连接） |
| 5 | `/order` | `order/order_list_page.dart` | `MyOrderActivity` | 部分（企划 / 商品一级 Tab，商品 Tab 为显式空态；待评论用 completed 近似） |
| 6 | `/me` | `user/user_page.dart` | `UserFragment` | 部分（资料/订单/资产/菜单卡，缺想看卡） |
| 7 | `/login` | `auth/login_page.dart` | `LoginActivity` | **高**（已接真实接口，验证码/密码/图形验证码） |
| 8 | `/show/:showId` | `goods/show_detail_page.dart` | `ShowDetailActivity` | 部分（详情本体完成；选座为独立路由，代抢/拼团为独立路由，缺评价） |
| 9 | `/show/:showId/choose-ticket` | `goods/choose_ticket_page.dart` | `ChooseSkuActivity` + `SelectTicketNormalActivity` | 部分（场次/票档/数量；选座见 `/show/:showId/seat-selection`） |
| 10 | `/venue/:name` | `goods/venue_page.dart` | `VenueDetailActivity` | 部分（场馆信息 + 近期演出，缺地图） |
| 11 | `/category/:categoryId` | `catalog/ui/category_home_page.dart` | `CategoryHomeActivity` | 完成（分类 Tab + 子标签筛选 + 演出列表） |
| 12 | `/shows` | `catalog/ui/show_list_page.dart` | `HotListActivity` | 完成（排序 + 分类 Tab + 空态） |
| 13 | `/search` | `search/search_page.dart` | `SearchActivity` | 完成（历史/热搜/联想三态） |
| 14 | `/search/result` | `search/search_result_page.dart` | `SearchResultActivity` | 完成（分域结果：演出/动态） |
| 15 | `/feed/:id` | `discover/feed_detail_page.dart` | `FeedDetailActivity` | 部分（正文/评论/互动条/视频双通道，缺评论发布） |
| 16 | `/message/thread/:id` | `message/chat_page.dart` | `UserMsgDetailActivity` | **高**（气泡列表 + 输入栏 + `v1/chat/threads` 收发/已读，缺长连接推送） |
| 17 | `/order/confirm` | `order/order_confirm_page.dart` | `OrderConfirmActivity` | **高**（优惠券/观演人/限购/金额试算/提交；支付见 `/order/pay`） |
| 18 | `/order/detail` | `order/order_detail_page.dart` | `OrderDetailWebActivity` | 部分（7 种状态 + 动作栏；退款已接真实接口，缺物流） |
| 19 | `/order/pay-success` | `order/pay_success_page.dart` | `PaySuccessActivity` | 完成（结果页 + 订单摘要 + 继续浏览） |
| 20 | `/settings` | `user/settings_page.dart` | `MoreSettingActivity` | 部分（深色模式/退出/意见反馈，其余 toast 占位） |
| 21 | `/address` | `user/address_page.dart` | `AddressListActivity` + `AddAddressActivity` | 完成（列表/新增/编辑/删除/设默认） |
| 22 | `/cities` | `home/city_list_page.dart` | `CityListActivity` | 部分（热门/全部城市，缺 A-Z 索引/定位） |
| 23 | `/me/edit-profile` | `user/edit_profile_page.dart` | `EditProfileActivity` | 部分（昵称/性别/简介，toast 占位提交） |
| 24 | `/feedback` | `user/feedback_page.dart` | `FeedbackActivity` | 完成（分类/内容/联系方式，toast 占位提交） |
| 25 | `/show/:showId/seat-selection` | `goods/seatmap/seat_selection_page.dart` | `SelectTicketSeatMapActivity` | 部分（本地锁座 + 连座校验 + mm:ss 倒计时；座位图/库存为本地数据） |
| 26 | `/bilibili/:bvid` | `discover/bilibili_player_page.dart` | `VideoPlayerActivity` | 完成（WebView 内嵌 B 站播放器） |
| 27 | `/order/pay` | `order/payment/pay_page.dart` | `PayActivity` | **高**（服务端支付单 + 轮询；未调起第三方 SDK） |
| 28 | `/order/refund` | `order/refund/refund_page.dart` | `OrderRefundWebActivity` | **高**（`POST/GET /v1/order/{id}/refund` 已接通） |
| 29 | `/coupons` | `marketing/coupon_page.dart` | `CouponActivity` | 部分（三 Tab；演示数据） |
| 30 | `/coupons/exchange` | `marketing/exchange_coupon_page.dart` | `ExchangeCouponActivity` | 部分（兑换码；演示数据） |
| 31 | `/wallet` | `marketing/wallet_page.dart` | `MyWalletActivity` | 部分（余额 + 流水；演示数据） |
| 32 | `/giftcards` | `marketing/giftcard/gift_card_page.dart` | `GiftCardActivity` | 部分（面值色块；演示数据） |
| 33 | `/giftcards/add` | `marketing/giftcard/add_gift_card_page.dart` | `AddGiftCardActivity` | 部分（绑定表单；演示数据） |
| 34 | `/proxy-buy` | `proxy_buy/ui/proxy_buy_page.dart` | `ProxyBuyChooseTicketActivity` | 部分（四层结构；后端无对应端点） |
| 35 | `/group-buy` | `group_buy/ui/group_buy_page.dart` | `PinTuanChooseTicketPurchaseFragment` | 部分（四层结构；后端无对应端点） |
| 36 | `/group-buy/:id` | `group_buy/ui/group_buy_detail_page.dart` | `PinTuanOrderListActivity` | 部分（四层结构；后端无对应端点） |

---

## 1. 未实现模块总表

| 模块 | Android 界面数 | 缺失代表页面 | 未实现原因 | 建议优先级 |
|------|-------------|-----------|---------|----------|
| ~~支付~~ | ~~3~~ | ~~`PayActivity`~~ | ~~已实现（pay_page.dart，服务端支付单 + 轮询；未调第三方 SDK）~~ | ~~P0~~ ✅ |
| ~~选座~~ | ~~5~~ | ~~`SelectTicketSeatMapActivity`~~ | ~~已实现（seat_selection_page.dart，本地锁座 + 连座 + 倒计时）~~ | ~~P0~~ ✅ |
| ~~优惠券 / 红包~~ | ~~3~~ | ~~`CouponActivity` / `ExchangeCouponActivity`~~ | ~~已实现（coupon_page.dart + exchange_coupon_page.dart，三 Tab + 兑换码）~~ | ~~P1~~ ✅ |
| ~~礼品卡~~ | ~~2~~ | ~~`GiftCardActivity` / `AddGiftCardActivity`~~ | ~~已实现（gift_card_page.dart + add_gift_card_page.dart，面值色块 + 绑定）~~ | ~~P1~~ ✅ |
| ~~钱包~~ | ~~1~~ | ~~`MyWalletActivity`~~ | ~~已实现（wallet_page.dart，余额 + 交易记录）~~ | ~~P1~~ ✅ |
| ~~退款~~ | ~~2~~ | ~~`OrderRefundWebActivity`~~ | ~~已实现（refund_page.dart，`POST/GET /v1/order/{id}/refund`）~~ | ~~P1~~ ✅ |
| ~~代抢~~ | ~~2~~ | ~~`ProxyBuyChooseTicketActivity` / `ProxyBuyConfirmActivity`~~ | ~~已实现并四层拆分；后端未注册对应端点~~ | ~~P1~~ ✅ |
| ~~拼团~~ | ~~3~~ | ~~`PinTuanChooseTicketPurchaseFragment` / `PinTuanOrderListActivity`~~ | ~~已实现并四层拆分；后端未注册对应端点~~ | ~~P1~~ ✅ |
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

> 表中 `✅` 表示**页面已实现**，不代表已接真实接口。支付、选座、营销、退款、代抢、
> 拼团目前都是本地模拟流程，真实数据 / SDK / 库存仍待接，见 §2.1–§2.7。

---

## 2. 逐模块详细说明

### 2.1 支付（P0）

**Android 对应**：`PayActivity` / `CmbPayWebActivity` / `WXPayEntryActivity` / `AbcPayEntryActivity`

**现状**：**已接真实支付单**，路由 `/order/pay`，代码在
`lib/features/order/payment/pay_page.dart` + `pay_providers.dart`。具备渠道选择、
15 分钟倒计时、`idle → requesting → paying → success / failure / cancelled`
状态机；`OrderConfirmPage` 提交后进入该页，成功后跳 `/order/pay-success`。
真实模式调用 `POST v1/unifiedPay/pay` 创建支付单，再每 2 秒轮询
`GET v1/unifiedPay/payDetail` 直到 success / failed / expired；演示分支仅在
`PS_USE_DEMO=true` 时进入，且明确标注为演示。

**未接第三方渠道 SDK**：
- 未调用微信（`fluwx`）/ 支付宝 / 银联 SDK，真实模式依赖服务端支付状态推进；
- 无客户端签名校验与渠道结果回调；
- 招商银行 H5（`CmbPayWebActivity`）未实现——当前项目无专用 WebView 支付容器；
- 失败 / 取消态在本页展示，订单状态以服务端查询为准。

**待接清单**：
- 微信 / 支付宝 / 银联 SDK 与平台配置；
- 支付超时、库存释放与订单取消的服务端联动。

---

### 2.2 选座（P0）

**Android 对应**：`SelectTicketSeatMapActivity` / `SelectTicketNormalActivity` / `ChooseTicketSeatMapFragment` / `ChooseTicketSeatTableFragment` / `SelectTicketBaseActivity`

**现状**：**页面已实现**，路由 `/show/:showId/seat-selection`，代码在
`lib/features/goods/seatmap/`：`seat_selection_page.dart`（舞台标签 → 座位图 →
已选列表 → 底部确认栏 + 10 分钟倒计时）、`seat_map_webview.dart`（WebView 渲染，
`seat_map.html` 负责手势 / 缩放）、`seat_map.dart`（区域 → 排 → 座三级模型）、
`seat_selection_providers.dart`、`seat_lock_service.dart`（本地锁表）、
`domain/seat_continuity_policy.dart`（连座校验）。

**未接真实数据 / 库存**：
- 座位图数据来自 `demo_seat_map.dart`，未对接座位图数据源；采用**网格表格模式**
  对齐 `ChooseTicketSeatTableFragment`，未使用 Mapbox；
- **锁座为本地锁，服务端座位库存未接入**：`SeatLockService` 只在当前 App 进程内
  维护「座位 ID → 到期时间」，默认 TTL 10 分钟；换设备 / 重启 / 其他用户不可见，
  没有服务端占座，也没有 `checkGoodStock` 库存校验；
- 连座校验已实现（同一区域 + 同一排 + 列号连续），进入确认页前拦截；
- 选座倒计时已实现（10 分钟，归零清空并释放本地锁），但未与服务端库存释放联动；
- 未与订单草稿打通：选好的座位尚未传入确认页 / 提单请求。

**待接清单**：
- 座位图数据接口（区域 / 排 / 座位状态）；
- **服务端锁座与释放、库存校验**（替换本地 `SeatLockService`，并把锁定座位
  下发给 WebView 置灰）；
- 连座规则与订单草稿联动。

---

### 2.3 优惠券 / 红包（P1）

**Android 对应**：`CouponActivity` / `CouponShowActivity` / `ExchangeCouponActivity` / `DiscountListActivity`

**现状**：**页面已实现**：`lib/features/marketing/coupon_page.dart`（未使用 / 已使用 /
已过期三 Tab）、`exchange_coupon_page.dart`（兑换码）；确认页也有券选择位。数据来自
`demo_coupons.dart` / `coupon_providers.dart`，**未接真实接口**。

**待接**：
- `v1/coupon/list`、`v1/coupon/exchange`、`v1/coupon/available`；
- 可用券筛选、互斥规则与订单报价的服务端校验；
- 首页「领券中心」（`CouponShowActivity`）入口未迁移。

---

### 2.4 礼品卡（P1）

**Android 对应**：`GiftCardActivity` / `AddGiftCardActivity`

**现状**：**页面已实现**：`lib/features/marketing/giftcard/gift_card_page.dart`（列表）
与 `add_gift_card_page.dart`（卡号 + 密码绑定），数据为本地演示值。

**待接**：
- `v1/giftcard/list`、`v1/giftcard/bind`；
- 与下单金额的抵扣联动、使用记录。

---

### 2.5 钱包（P1）

**Android 对应**：`MyWalletActivity`

**现状**：**页面已实现**：`lib/features/marketing/wallet_page.dart`（余额 + 交易记录），
数据来自演示常量；`UserPage` 资产卡的余额同样是演示值。

**待接**：
- `v1/wallet/balance`、`v1/wallet/transactions`；
- 充值 / 提现流程（充值需复用支付渠道，提现需绑卡）。

---

### 2.6 退款（P1）

**Android 对应**：`OrderRefundWebActivity` + 退款申请页

**现状**：**页面与接口已接通**：`lib/features/order/refund/refund_page.dart`（原生退款表单），
订单详情页（状态相关动作）可跳转 `/order/refund`。真实模式走
`POST /v1/order/{id}/refund` 申请、`GET /v1/order/{id}/refund` 查询进度；
演示模式仅受 `PS_USE_DEMO=true` 控制。

**待接**：
- 退款金额明细展示（按「已出票 / 未出票」规则由服务端计算）；
- 退款结果通知（推送 / 站内信）。

---

### 2.7 代抢 / 拼团 / 求票（P1）

**Android 对应**：`ProxyBuyChooseTicketActivity` / `ProxyBuyConfirmActivity` / `PinTuanChooseTicketPurchaseFragment` / `PinTuanOrderListActivity`

**现状**：**代抢与拼团已按 `ui / application / domain / data` 四层拆分**：
`lib/features/proxy_buy/ui/proxy_buy_page.dart`（规则 + 截止选项 + 订单列表）、
`lib/features/group_buy/ui/group_buy_page.dart` 与 `group_buy_detail_page.dart`
（进度条 + 成员头像 + 参团）。页面本身不发起 API、不做定价计算、不写
`Future.delayed`；真实模式由 data 层调用 `v1/proxyBuyOrder/myOrders`、
`v1/pinTuanOrder/*`、`v1/pinTuanCampaign/{id}`。这 4 条是来源 Android 的遗留路径，
**当前后端未注册**，真实模式会 404；演示模式不受影响。求票浮球仍未迁移。

**待接**：
- 后端实现代抢 / 拼团端点；
- 拼团分享拉人（依赖分享能力，见 §2.14）；
- 求票浮球与求票信息表单。

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

**现状**：发现页 / 动态详情遇到 B 站视频时弹出「应用内播放 / 打开哔哩哔哩」两个选项
（`discover/widgets/bilibili_open_sheet.dart`）：应用内走 `/bilibili/:bvid`
（`ui/bilibili_player_page.dart`，WebView 内嵌官方播放器），外部走
`bilibili://video/<bvid>`，未安装客户端时回退网页版。

**缺失内容**：
- 自有视频播放器内核（ExoPlayer 等价物），目前复用 B 站 WebView；
- 沉浸式视频流（上下滑动切换）；
- 视频详情页（自有视频 + 信息 + 评论）；
- 精选视频列表。

**未实现原因**：自有播放器需要 CDN 配置、缓冲策略、codec 适配。

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
| **后端接线** | 全部模块 | 后端注册 **46 条路由 / 45 个唯一端点**；客户端 `ApiPaths.all` 33 条，其中 29 条在后端有对应注册。已接通 `auth` / `catalog` / `feed` / `message`（含 `v1/chat/threads`）/ `order`（含支付、退款）/ `user`（含地址）。演示开关为 `--dart-define=PS_USE_DEMO=true`。仍缺的是**后端没有端点**的能力：代抢/拼团（4 条遗留路径）、选座锁座、优惠券/钱包、评价、推送，见 §2.1–§2.7。 |
| **图片资源** | 全部页面 | 138 张图里没有海报 / 分类图标。海报走 `PsPoster` 渐变占位。 |
| **文案 l10n** | 全部页面 | 已按 feature 拆分到 `lib/l10n/arb/**`（13 个命名空间 / 922 条），`tool/gen_l10n.dart --check` 保持一致。 |
| **A/B 测试 / 埋点** | 全部页面 | Android 有完整埋点体系（`Statistics` / `TrackEvent`），Flutter 侧无。 |
| **推送** | 消息 / 订单 | Android 用 JPush，Flutter 侧无推送能力。 |
| **IM 长连接** | 消息 | Android 用环信 IM；Flutter 侧已接 `v1/chat/threads` 收发/已读接口，但没有长连接与推送。 |
| **地图 / 定位** | 场馆 / 城市 | Android 用高德地图，Flutter 侧无地图 SDK。 |
| **资源流水线** | 全部页面 | 2,387 个 drawable 里的 `.9.png` / `selector` / `shape` / `vector` 没有等价物。 |

---

## 3. 建议推进顺序

按「一条链路打穿」而非「一个模块均匀铺开」排——前者能验证架构，后者只会摊薄。

| 期 | 目标 | 涉及模块 | 完成标志 |
|----|------|--------|--------|
| **P0** | 购票主链路接真实后端 | 支付 → 选座 | 页面已存在；完成标志是一条真实订单能选中真实座位 → 下单 → 真实渠道支付 → 查看详情 |
| **P1** | 交易分支接真实接口 | 优惠券 / 礼品卡 / 钱包 / 退款 / 代抢 / 拼团 | 页面已在，交易域 8 个界面完成真实数据与支付联动 |
| **P2** | 内容与社交 | 评论 / 话题 / 视频 / 文章 / 社区 / 分享 | `discovery` + `feed` + `video` 核心界面 |
| **P3** | 长尾收尾 | WebView / 演员 / 图集 / 日历 / 商城 / 关于 / 账号安全 / 实名 / 个人主页 / 推荐 | 剩余约 40 个界面 |

---

## 4. 相关文档

- [page-parity.md](page-parity.md) — 已实现页面的逐页对照说明
- [api-contract.md](api-contract.md) — 后端接口契约（登录域已接通）
- [ddd-order-domain.md](ddd-order-domain.md) — 订单领域模型设计
- `wiki_zh/31-flutter-parity-gap.md` — 18 路由时点的完整差距分析（历史快照）
