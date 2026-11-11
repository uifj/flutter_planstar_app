# 未实现模块清单

> 适用版本：planstar Flutter 1.0.1 · 最后核对：2026-11-11 · 维护：客户端组

> **时点**：2026-11-11 文档核对  
> **项目快照**：39 个路由页（`lib/app/router.dart`）  
> **静态检查**：以 `flutter analyze` / `flutter test` 门禁结果为准，本文不快照具体数字

本文档逐模块列出尚未实现的页面与功能，
并标注**未实现的原因**和**实现建议**，供后续迭代参考。

---

## 0. 已实现模块速览（39 页）

| # | 路由 | 页面文件 | 完成度 |
|---|------|---------|-------|
| 1 | `/splash` | `app/splash_page.dart` | 完成（隐私门 + 品牌闪屏 2s） |
| 2 | `/` | `home/home_page.dart` | 部分（楼层顺序见该页库级注释，缺服务端配置型运营楼层） |
| 3 | `/discover` | `discover/discover_page.dart` | 部分（热门/关注 + 发布，缺话题/视频） |
| 4 | `/message` | `message/message_page.dart` | 部分（会话列表 + 三角色卡，缺 IM 长连接） |
| 5 | `/order` | `order/order_list_page.dart` | 部分（企划 / 商品一级 Tab，商品 Tab 为显式空态；待评论用 completed 近似） |
| 6 | `/me` | `user/user_page.dart` | 部分（资料/订单/资产/菜单卡，缺想看卡） |
| 7 | `/login` | `auth/login_page.dart` | **高**（已接真实接口，验证码/密码/图形验证码） |
| 8 | `/show/:showId` | `goods/show_detail_page.dart` | 部分（详情本体完成；选座、代抢/组队支持为独立路由，缺评价） |
| 9 | `/show/:showId/choose-ticket` | `goods/choose_ticket_page.dart` | 部分（线下回报场次/回报档位/数量；选座见 `/show/:showId/seat-selection`） |
| 10 | `/venue/:name` | `goods/venue_page.dart` | 部分（活动场地信息 + 近期企划，缺地图） |
| 11 | `/category/:categoryId` | `catalog/ui/category_home_page.dart` | 完成（分类 Tab + 子标签筛选 + 企划列表） |
| 12 | `/shows` | `catalog/ui/show_list_page.dart` | 完成（排序 + 分类 Tab + 空态） |
| 13 | `/search` | `search/search_page.dart` | 完成（历史/热搜/联想三态） |
| 14 | `/search/result` | `search/search_result_page.dart` | 完成（分域结果：企划/动态） |
| 15 | `/feed/:id` | `discover/feed_detail_page.dart` | 部分（正文/评论/互动条/视频双通道，缺评论发布） |
| 16 | `/message/thread/:id` | `message/chat_page.dart` | **高**（气泡列表 + 输入栏 + `v1/chat/threads` 收发/已读，缺长连接推送） |
| 17 | `/order/confirm` | `order/order_confirm_page.dart` | **高**（优惠券/实名支持者/限购/金额试算/提交；支付见 `/order/pay`） |
| 18 | `/order/detail` | `order/order_detail_page.dart` | 部分（`OrderStatus` 7 种状态 + 动作栏；退款已接真实接口，缺物流） |
| 19 | `/order/pay-success` | `order/pay_success_page.dart` | 完成（结果页 + 订单摘要 + 继续浏览） |
| 20 | `/settings` | `user/settings_page.dart` | 部分（深色模式/退出/意见反馈，其余 toast 占位） |
| 21 | `/address` | `user/address_page.dart` | 完成（列表/新增/编辑/删除/设默认） |
| 22 | `/cities` | `home/city_list_page.dart` | 部分（热门/全部城市，缺 A-Z 索引/定位） |
| 23 | `/me/edit-profile` | `user/edit_profile_page.dart` | 部分（昵称/性别/简介，toast 占位提交） |
| 24 | `/feedback` | `user/feedback_page.dart` | 完成（分类/内容/联系方式，toast 占位提交） |
| 25 | `/show/:showId/seat-selection` | `goods/seatmap/seat_selection_page.dart` | 部分（本地锁座 + 连座校验 + mm:ss 倒计时；座位图/库存为本地数据） |
| 26 | `/bilibili/:bvid` | `discover/ui/bilibili_player_page.dart` | 完成（WebView 内嵌 B 站播放器） |
| 27 | `/order/pay` | `order/payment/pay_page.dart` | **高**（服务端支付单 + 轮询；未调起第三方 SDK） |
| 28 | `/order/refund` | `order/refund/refund_page.dart` | **高**（`POST/GET /v1/order/{id}/refund` 已接通） |
| 29 | `/coupons` | `marketing/coupon_page.dart` | 部分（三 Tab；演示数据） |
| 30 | `/coupons/exchange` | `marketing/exchange_coupon_page.dart` | 部分（兑换码；演示数据） |
| 31 | `/wallet` | `marketing/wallet_page.dart` | **高**（星币余额 + 流水，已接 `v1/moneyaccount*`；充值/提现已隐藏） |
| 32 | `/giftcards` | `marketing/giftcard/gift_card_page.dart` | 部分（面值色块；演示数据） |
| 33 | `/giftcards/add` | `marketing/giftcard/add_gift_card_page.dart` | 部分（绑定表单；演示数据） |
| 34 | `/proxy-buy` | `proxy_buy/ui/proxy_buy_page.dart` | 部分（四层结构；后端无对应端点，遗留票务能力待下线） |
| 35 | `/group-buy` | `group_buy/ui/group_buy_page.dart` | 部分（四层结构；后端无对应端点） |
| 36 | `/group-buy/:id` | `group_buy/ui/group_buy_detail_page.dart` | 部分（四层结构；后端无对应端点） |
| 37 | `/project-idea` | `project_idea/project_idea_page.dart` | **高**（星推官叠卡流：支持=通过 / 不支持=驳回，游标翻页 + 表态弹窗） |
| 38 | `/project-idea/:ideaId` | `project_idea/project_idea_detail_page.dart` | **高**（创意详情 + 「尚未立项」标注 + 支持/不支持弹窗） |
| 39 | `/mall` | `mall/mall_page.dart` | **高**（星币余额 + 商品规格 + 兑换，已接 `v1/shop/goods*`） |

---

## 1. 未实现模块总表

| 模块 | 缺失代表页面 | 未实现原因 | 建议优先级 |
|------|-----------|---------|----------|
| ~~支付~~ | ~~支付页 / 渠道结果回调~~ | ~~已实现（pay_page.dart，服务端支付单 + 轮询；未调第三方 SDK）~~ | ~~P0~~ ✅ |
| ~~选座~~ | ~~座位图选座页~~ | ~~已实现（seat_selection_page.dart，本地锁座 + 连座 + 倒计时）~~ | ~~P0~~ ✅ |
| ~~优惠券 / 红包~~ | ~~券列表 / 兑换码页~~ | ~~已实现（coupon_page.dart + exchange_coupon_page.dart，三 Tab + 兑换码）~~ | ~~P1~~ ✅ |
| ~~礼品卡~~ | ~~礼品卡列表 / 绑定页~~ | ~~已实现（gift_card_page.dart + add_gift_card_page.dart，面值色块 + 绑定）~~ | ~~P1~~ ✅ |
| ~~钱包~~ | ~~星币钱包页~~ | ~~已实现（wallet_page.dart，余额 + 交易记录，已接 `v1/moneyaccount*`）~~ | ~~P1~~ ✅ |
| ~~退款~~ | ~~退款申请页~~ | ~~已实现（refund_page.dart，`POST/GET /v1/order/{id}/refund`）~~ | ~~P1~~ ✅ |
| ~~代抢~~ | ~~代抢选择 / 确认页~~ | ~~已实现并四层拆分；后端未注册对应端点（遗留票务能力，待下线）~~ | ~~P1~~ ✅ |
| ~~组队支持~~ | ~~组队支持列表 / 详情页~~ | ~~已实现并四层拆分；后端未注册对应端点~~ | ~~P1~~ ✅ |
| ~~星币商城~~ | ~~商城首页 / 商品规格 / 兑换~~ | ~~已实现（mall_page.dart，已接 `v1/shop/goods*`）~~ | ~~P3~~ ✅ |
| 评论 / 评价 | 写评价页 / 评价列表页 / 我的评价页 / 订单评价入口 | 需图片上传与评价 UI；后端已注册 `v1/projects/{id}/reviews`，客户端未接 | P2 |
| 话题 | 话题详情 / 热门话题 / 我的话题 / 话题搜索 / 标签动态列表 | 需话题数据源 | P2 |
| 视频播放 | 自有播放器 / 沉浸式视频流 / 视频详情 / 精选视频列表 | 需 CDN + 播放器内核 | P2 |
| 视频录制 | 录制 / 裁剪 / 编辑 / 发送 | 需相机权限 + 裁剪 SDK | P2 |
| 文章 | 文章详情 / 文章创建 | 需文章服务接口 | P2 |
| 社区详情 | 社区详情 / 已关注社区 / 关联社区搜索 | 需社区数据源 | P2 |
| 分享 | 底部分享面板 / 分享图片生成 / 小程序分享 | 需 fluwx / 系统分享 | P2 |
| WebView / JsBridge | 通用 WebView 页 / JS 桥 / 小程序容器 | 需 webview_flutter + JS 桥协议 | P3 |
| 创作者 / 关注 | 创作者详情 / 关注列表 / 创作者搜索 / 我关注的创作者 | 后端已注册 `v1/creators/{id}`，客户端未接 | P3 |
| 图集 / 相册 | 企划图集 / 全屏图片预览 / 图片下载 | 需图片浏览组件 | P3 |
| 日历 | 线下回报场次日历 | 需日历数据源 | P3 |
| 实物商品域 | 实物商品详情 / 商品订单详情 / 商品订单 Tab / 购物车 | 需独立商品域聚合（星币商城已实现，见上） | P3 |
| 关于 / 协议 | 关于页 / 用户协议页 / 隐私政策页 | 需 WebView 或静态页 | P3 |
| 账号安全 | 修改密码 / 换绑手机 / 忘记密码 / 一键登录 / 注销账号 / 商务合作 | 需账号安全服务 | P3 |
| 实名认证 | 实名支持者列表 / 添加证件 | 需 id 聚合服务 | P3 |
| 个人主页 | 用户公开主页 / 头像主页 | 需用户公开资料接口 | P3 |
| 推荐 / 关联 | 楼层推荐列表 / 关联企划搜索 / 标签搜索结果 | 运营配置型，需后端 schema | P3 |
| 通用 / 调试 | 弹层容器 / AppLink / 浏览模式列表 / 调试页 | 壳层 / 调试工具 | P3 |

**合计**：上表未划掉的模块即当前缺口，逐模块明细见 §2；不再按「界面单元」计数。

> 表中 `✅` 表示**页面已实现**，不代表已接真实接口。支付、退款、星币钱包、星币商城
> 已接真实接口；选座、优惠券、礼品卡、代抢、组队支持仍是本地数据 / 本地模拟流程，
> 真实数据 / SDK / 库存仍待接，见 §2.1–§2.7。

---

## 2. 逐模块详细说明

### 2.1 支付（P0）

**现状**：**已接真实支付单**，路由 `/order/pay`，代码在
`lib/features/order/payment/pay_page.dart` + `pay_providers.dart`。具备渠道选择、
倒计时（真实模式优先取支付单的 `expireAt`，创建前用订单支付窗口；演示数据
`PayInfo.demo` 写死 900 秒）、`idle → requesting → paying → success / failure / cancelled`
状态机；`OrderConfirmPage` 提交后进入该页，成功后跳 `/order/pay-success`。
真实模式调用 `POST v1/unifiedPay/pay` 创建支付单，再每 2 秒轮询
`GET v1/unifiedPay/payDetail` 直到 success / failed / expired；演示分支仅在
`PS_USE_DEMO=true` 时进入，且明确标注为演示。

**未接第三方渠道 SDK**：
- 未调用微信（`fluwx`）/ 支付宝 / 银联 SDK，真实模式依赖服务端支付状态推进；
- 无客户端签名校验与渠道结果回调；
- 银行 H5 支付未实现——当前项目无专用 WebView 支付容器；
- 失败 / 取消态在本页展示，订单状态以服务端查询为准。

**待接清单**：
- 微信 / 支付宝 / 银联 SDK 与平台配置；
- 支付超时、库存释放与订单取消的服务端联动。

---

### 2.2 选座（P0）

**遗留定位**：座位图是线下回报场次的可选降级能力（POSITIONING.md §10），
仅线下活动型企划使用，不是企划支持主链路的必经步骤。

**现状**：**页面已实现**，路由 `/show/:showId/seat-selection`，代码在
`lib/features/goods/seatmap/`：`seat_selection_page.dart`（舞台标签 → 座位图 →
已选列表 → 底部确认栏 + 10 分钟倒计时）、`seat_map_webview.dart`（WebView 渲染，
`seat_map.html` 负责手势 / 缩放）、`seat_map.dart`（区域 → 排 → 座三级模型）、
`seat_selection_providers.dart`、`seat_lock_service.dart`（本地锁表）、
`domain/seat_continuity_policy.dart`（连座校验）。

**未接真实数据 / 库存**：
- 座位图数据来自 `demo_seat_map.dart`，未对接座位图数据源；采用**网格表格模式**，
  不做地图引擎（不渲染活动场地俯视图）；
- **锁座为本地锁，服务端座位库存未接入**：`SeatLockService` 只在当前 App 进程内
  维护「座位 ID → 到期时间」，默认 TTL 10 分钟；换设备 / 重启 / 其他用户不可见，
  没有服务端占座，也没有库存校验接口；
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

**现状**：**页面已实现**：`lib/features/marketing/coupon_page.dart`（未使用 / 已使用 /
已过期三 Tab）、`exchange_coupon_page.dart`（兑换码）；确认页也有券选择位。数据来自
`demo_coupons.dart` / `coupon_providers.dart`，**未接真实接口**。

**待接**：
- `v1/coupon/list`、`v1/coupon/exchange`、`v1/coupon/available`；
- 可用券筛选、互斥规则与订单报价的服务端校验；
- 首页「领券中心」入口未实现。

---

### 2.4 礼品卡（P1）

**现状**：**页面已实现**：`lib/features/marketing/giftcard/gift_card_page.dart`（列表）
与 `add_gift_card_page.dart`（卡号 + 密码绑定），数据为本地演示值。

**待接**：
- `v1/giftcard/list`、`v1/giftcard/bind`；
- 与下单金额的抵扣联动、使用记录。

---

### 2.5 钱包（P1）

**现状**：**页面与接口已接通**：`lib/features/marketing/wallet_page.dart`（星币余额 +
交易记录）。真实模式走 `GET v1/moneyaccount` + `GET v1/moneyaccount/sequences`
（`walletProvider`）；`UserPage` 资产卡的余额同源（`walletBalanceProvider`，
服务端资料优先）；每日签到走 `GET/POST v1/user/signIn`。演示模式仅受
`PS_USE_DEMO=true` 控制。充值 / 提现 / 第三方支付入口已隐藏。

**待接**：
- 充值 / 提现流程（充值需复用支付渠道，提现需绑卡）；
- 优惠券 / 礼品卡与星币余额的抵扣联动（券与卡仍是演示数据，见 §2.3 / §2.4）。

---

### 2.6 退款（P1）

**现状**：**页面与接口已接通**：`lib/features/order/refund/refund_page.dart`（原生退款表单），
订单详情页（状态相关动作）可跳转 `/order/refund`。真实模式走
`POST /v1/order/{id}/refund` 申请、`GET /v1/order/{id}/refund` 查询进度；
演示模式仅受 `PS_USE_DEMO=true` 控制。

**待接**：
- 退款金额明细展示（按回报履约状态由服务端计算）；
- 退款结果通知（推送 / 站内信）。

---

### 2.7 代抢 / 组队支持 / 求票（P1）

**遗留定位**：代抢与求票属于遗留票务叙事（POSITIONING.md §10 待下线），组队支持
保留社交裂变、去掉票务心智。本节记录代码现状，不是要新建的企划能力。

**现状**：**代抢与组队支持已按 `ui / application / domain / data` 四层拆分**：
`lib/features/proxy_buy/ui/proxy_buy_page.dart`（规则 + 截止选项 + 订单列表）、
`lib/features/group_buy/ui/group_buy_page.dart` 与 `group_buy_detail_page.dart`
（进度条 + 成员头像 + 参与）。页面本身不发起 API、不做定价计算、不写
`Future.delayed`；真实模式由 data 层调用 `v1/proxyBuyOrder/myOrders`、
`v1/pinTuanOrder/*`、`v1/pinTuanCampaign/{id}`。这 4 条是遗留票务路径，
**当前后端未注册**，真实模式会 404；演示模式不受影响。求票浮球仍未实现。

**待接**：
- 代抢 / 求票按 POSITIONING.md §10 待下线；组队支持若要接真实数据，需要后端提供
  企划域端点（当前 4 条遗留路径未注册）；
- 组队支持分享拉人（依赖分享能力，见 §2.14）。

---

### 2.8 评论 / 评价（P2）

**现状**：`FeedDetailPage` 的评论区是只读的（toast 说明"评论发布待接入"）。企划详情页没有评价区。订单完成后"去评价"按钮跳到的页面不存在。

**缺失内容**：
- 写评价页（评分 / 文字 / 图片上传 / 匿名）
- 评价列表页（企划评价列表 + 排序 + 有用）
- 我的评价页（已写 / 待写）
- 订单评价入口

**实现建议**：
- 新建 `lib/features/review/` 模块
- 评分用 5 星组件（自绘）
- 图片上传走 `package:core/upload.dart`（分片引擎 + OSS 表单直传）
- 后端已注册 `GET/POST v1/projects/{id}/reviews`，客户端尚未封装；字段以
  `planstar_kratos_server/docs/api/API_CONTRACT.md` 为准。早期设想的
  `v1/review/create` + `v1/review/list` 后端并未注册，不要按它们建 DTO

---

### 2.9 话题（P2）

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

**现状**：发现页 / 动态详情遇到 B 站视频时弹出「应用内播放 / 打开哔哩哔哩」两个选项
（`discover/widgets/bilibili_open_sheet.dart`）：应用内走 `/bilibili/:bvid`
（`ui/bilibili_player_page.dart`，WebView 内嵌官方播放器），外部走
`bilibili://video/<bvid>`，未安装客户端时回退网页版。

**缺失内容**：
- 自有视频播放器内核，目前复用 B 站 WebView；
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

**现状**：`DiscoverPage` 的发布按钮只支持图文动态，不支持视频。

**缺失内容**：
- 视频录制（相机权限 + 预览 + 录制）
- 视频裁剪
- 视频编辑（滤镜 / 配乐 / 贴纸）
- 视频发送（上传 + 发布）

**实现建议**：
- 相机层用 `camera` 包
- 裁剪 / 编辑需要专门的 SDK（相机预览、时间轴裁剪、滤镜渲染都不在 Flutter 标准库里）
- 上传走 `package:core/upload.dart`

---

### 2.12 文章（P2）

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

**现状**：`DiscoverPage` 没有社区概念。

**缺失内容**：
- 社区详情页（社区简介 + 成员 + 动态列表）
- 已关注社区列表
- 关联社区搜索

**实现建议**：
- 与话题模块同源，可合并到 `topic` 或独立 `community` 模块

---

### 2.14 分享（P2）

**现状**：所有页面的分享按钮都是 toast（"分享面板待接入 fluwx"）。

**缺失内容**：
- 底部分享面板（微信好友 / 朋友圈 / QQ / 微博 / 复制链接 / 生成图片）
- 生成分享图片（企划海报 + 二维码）
- 分享到微信小程序

**实现建议**：
- 引入 `fluwx`（微信分享）
- 分享图片生成用 `RepaintBoundary` + `toImage`
- 底部面板用 `showModalBottomSheet`（复用支付渠道面板已抽出的公共组件模式）

---

### 2.15 WebView / JsBridge（P3）

**现状**：设置页的"用户协议""隐私政策"是 toast，没有通用 WebView 页面
（座位图已有专用 WebView 容器，见 §2.2）。

**缺失内容**：
- 通用 WebView 页（加载 URL + 标题 + 进度条 + 返回）
- JSBridge（原生 ↔ H5 通信协议）
- 微信小程序容器

**实现建议**：
- 引入 `webview_flutter`
- JSBridge 需要自定一套 scheme 与消息协议，并对调用方做来源校验
- 协议页 / 隐私政策 / 招行一网通 H5 支付都需要 WebView（退款已是原生页，见 §2.6）

---

### 2.16 创作者 / 关注（P3）

**现状**：`ShowDetailPage` 有创作者信息固定区块，但没有独立的创作者主页，
也没有关注列表。

**缺失内容**：
- 创作者详情页（头像 / 简介 / 代表作品 / 关注按钮）
- 创作者关注列表
- 创作者搜索
- 我关注的创作者

**实现建议**：
- 新建独立的创作者 feature 模块（沿用 `ui / application / domain / data` 四层）
- 后端已注册 `GET v1/creators/{id}`，客户端尚未封装；早期设想的
  `v1/actor/detail` + `v1/actor/follow` 后端并未注册
- 创作者详情页结构类似 `VenuePage`

---

### 2.17 图集 / 相册（P3）

**现状**：`ShowDetailPage` 的头部海报是单张，没有图集浏览。

**缺失内容**：
- 企划图集（多张宣传图滑动浏览）
- 全屏图片预览（双指缩放 / 左右切换）
- 图片下载

**实现建议**：
- 使用 `photo_view` 包实现缩放
- 图集用 `PageView`

---

### 2.18 日历（P3）

**现状**：首页没有日历入口。

**缺失内容**：
- 线下回报场次日历（按日期显示当天的线下回报场次）
- 日历筛选（分类 / 活动场地）

**实现建议**：
- 使用 `table_calendar` 包
- 数据来自 `catalog` 域（按日期过滤企划与线下回报场次）；企划没有城市维度
  （全国发行），不要按城市建筛选

---

### 2.19 商城 / 实物商品域（P3）

**现状**：**星币商城已实现并接通**：路由 `/mall`，`lib/features/mall/mall_page.dart`
（星币余额 + 商品规格 + 兑换），真实模式走 `v1/shop/goods`、`v1/shop/goods/{id}`、
`v1/shop/goods/{id}/skus/{skuId}/redeem`。订单列表的"商品"Tab 仍是显式空状态。

**缺失内容**：
- 实物商品详情页
- 商品订单详情
- 购物车 / 下单流程

**实现建议**：
- 独立的商品域聚合（与企划支持链路平行）
- **不建议短期实现**——实物商城是独立业务线，当前应聚焦企划支持链路

---

### 2.20 关于 / 协议页（P3）

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

**现状**：设置页的"实名认证"是 toast（"属于独立的 id 聚合，本示例未实现"）。

**缺失内容**：
- 实名支持者列表（已认证的证件列表）
- 添加证件（姓名 + 证件类型 + 证件号 + 人脸识别）

**实现建议**：
- 人脸识别需第三方 SDK（旷视 / 商汤）
- **不建议短期实现**——合规要求高，SDK 依赖重

---

### 2.23 个人主页（P3）

**现状**：`UserPage` 是"我的"（自己看自己），没有"别人的主页"。

**缺失内容**：
- 用户公开主页（头像 / 昵称 / 简介 / 动态 / 关注 / 粉丝）
- 头像主页（点击头像看大图 + 动态）

**实现建议**：
- DTO 对齐 `v1/user/home`
- 动态列表复用 `FeedCard`

---

### 2.24 推荐 / 关联（P3）

**现状**：首页"推荐"楼层没有独立列表页。

**缺失内容**：
- 推荐企划列表（首页楼层"查看更多"）
- 关联企划搜索（创作者 / 活动场地 / 标签的关联企划）
- 标签搜索结果

**实现建议**：
- 复用 `ShowListPage`（已支持分类 + 排序）
- 标签 / 关联只是 filter 参数不同

---

### 2.25 首页缺失楼层（P3）

**现状**：首页楼层顺序固定在 `home_page.dart` 的库级注释里（顶部 / 分类快捷入口 /
运营 Banner / 服务保障条 / 精选企划 / 正在支持的企划 / 企划榜单 / 分类楼层 ×4 /
页脚），缺以下 4 类服务端配置型楼层：

| 缺失楼层 | 作用 | 未实现原因 |
|---------|------|---------|
| 运营位 | 服务端下发楼层类型 + 跳转 schema 拼装 | 无接口 → 无固定布局 → 硬造会得到"永远不对"的占位 |
| 瀑布流 | 异形卡瀑布流推荐 | 同上 |
| 创作者 / 活动场地推荐 | 热门创作者与线下活动场地推荐 | 无对应数据源接口 |
| 推荐词 | 搜索推荐词楼层 | 无推荐词接口 |

**实现建议**：
- 这些楼层是**服务端配置型**，没有接口就无法对齐
- 后端接线后按楼层类型分发到不同的 Widget 渲染

---

### 2.26 首页缺失二级页（P3）

**现状**：首页楼层没有"查看更多"跳转。

**缺失内容**：
- 楼层推荐列表
- 热门线下回报场次列表
- 日历企划列表

**实现建议**：
- 复用 `ShowListPage` + 不同 filter 参数

---

### 2.27 系统性缺口（跨模块）

| 缺口 | 影响范围 | 说明 |
|------|--------|------|
| **后端接线** | 全部模块 | 后端注册 **56 条路由 / 55 个唯一端点**；客户端 `ApiPaths.all` **42 条**，其中 **38 条**在后端有对应注册、**4 条**是遗留票务路径（真实模式 404）。已接通 `auth` / `catalog`（含 `v1/projects*`、`v1/rankings`）/ `project_idea` / `feed` / `message`（含 `v1/chat/threads`）/ `order`（含支付、退款）/ `user`（含地址、签到、星币钱包）/ `mall`。演示开关为 `--dart-define=PS_USE_DEMO=true`。仍缺的是**后端没有端点**的能力：优惠券 / 礼品卡、服务端锁座与库存、推送；代抢 / 组队支持的 4 条遗留路径后端未注册。后端已注册但客户端未调用的 **12 条路径**（含评价、创作者主页、支持记录）见 `api-contract.md` §5.5——它们不是「后端未实现」。 |
| **图片资源** | 全部页面 | `assets/` 只有 5 张应用图标 PNG 与座位图 HTML，没有海报 / 分类位图。海报走 `PsPoster` 渐变占位，分类快捷入口用 Lucide 矢量图标。 |
| **文案 l10n** | 全部页面 | 已按 feature 拆分到 `lib/l10n/arb/**`：app + 13 个 feature = **14 套 ARB / 996 条文案**（zh 模板 + en），生成产物在 `lib/l10n/generated/`，调用统一走扁平门面 `context.l10n.key`；`tool/gen_l10n.dart --check` 保持一致。 |
| **A/B 测试 / 埋点** | 全部页面 | 企划创意域已有事件名常量与统一记录入口（`ProjectIdeaEvents` / `trackProjectIdeaEvent`），但未接分析 SDK，只落 `debugPrint`；订单域只有内存领域事件记录器（`OrderEventRecorder`）。无 A/B 分流能力。 |
| **推送** | 消息 / 订单 | 无推送能力，也没有厂商通道接入。 |
| **IM 长连接** | 消息 | 已接 `v1/chat/threads` 收发/已读接口，但没有长连接与推送。 |
| **地图 / 定位** | 活动场地 / 城市 | 无地图 SDK，活动场地页与城市页都没有地图视图。 |
| **资源流水线** | 全部页面 | 图标统一走矢量图标库，没有位图素材与切图流水线。 |
| **语义门禁** | 全部文案 | `tool/check_forbidden_terms.dart` 只扫 Dart 字符串字面量与 ARB 文案值（不扫注释、ARB `description`、Markdown），禁用词：演出 / 观演 / 票档 / 抢票 / 代抢 / 开票 / 门票 / 剧院 / 演唱会 / 艺人；场次 / 座位仅在同一行含「线下」时放行。`tool/forbidden_terms_whitelist.json` 当前为空数组。 |

---

## 3. 建议推进顺序

按「一条链路打穿」而非「一个模块均匀铺开」排——前者能验证架构，后者只会摊薄。

| 期 | 目标 | 涉及模块 | 完成标志 |
|----|------|--------|--------|
| **P0** | 支持主链路补齐真实座位数据 | 选座（座位图 / 库存） | 支付已接真实后端（见 §2.1），本地锁座 / 连座 / 倒计时也已实现；完成标志是座位图与库存来自后端而非本地模拟，一条真实订单能选中真实座位 → 下单 → 真实渠道支付 → 查看详情。后端目前没有座位图 / 库存接口，需先补齐服务端能力。 |
| **P1** | 交易分支收尾 | 优惠券 / 礼品卡 / 代抢 / 组队支持 | 钱包与退款已接真实接口（见 §2.5、§2.6）；优惠券与礼品卡仍是本地模拟数据，完成标志是接真实接口并与支付联动。代抢 / 组队支持属遗留票务能力，先按 POSITIONING.md §10 定去留口径再决定是否接线（见 §2.7）。 |
| **P2** | 内容与社交 | 评论 / 话题 / 视频 / 文章 / 社区 / 分享 | §2.8–§2.14 列出的页面接上真实数据 |
| **P3** | 长尾收尾 | WebView / 创作者 / 图集 / 日历 / 商城 / 关于 / 账号安全 / 实名 / 个人主页 / 推荐 | §2.15–§2.26 列出的页面与首页楼层补齐；商城主链路已接真实接口（见 §2.19），此处剩实物商品域的扩展能力 |

---

## 4. 相关文档

- [page-parity.md](page-parity.md) — 已实现页面的逐页对照说明
- [api-contract.md](api-contract.md) — 后端接口契约与逐条接入状态（见其 §5）
- [ddd-order-domain.md](ddd-order-domain.md) — 订单领域模型设计

