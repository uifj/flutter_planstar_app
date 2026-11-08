# features/ 各页面对照 Android 原项目的完成情况

> 适用版本：planstar Flutter 1.0.1 · 最后核对：2026-11-07 · 维护：客户端组

> 口径：逐个页面拿 Android 原项目的 `res/layout/*.xml` 与
> `drawable/*`、`values/*` 当唯一依据核对，尺寸/字号/颜色**不靠感觉**，
> 每处刻意不一致都在代码的类文档注释里写明了原因。
> 本文件是那份注释的汇总，用来回答"哪些做完了、哪些还差"。

## 0. 总览

| 页面 | 来源布局 | 状态 | 主要差异 |
| --- | --- | --- | --- |
| 首页 | `fragment_home.xml` + 各 `view_home_*.xml` + `HomeMultiAdapter` | 完成（11 个楼层里做了 7 个） | 运营位/瀑布流/明星/推荐词等**服务端配置型**楼层不做 |
| 发现 | `fragment_discovery.xml` + 动态卡 | 完成 | 动态详情页、点赞/关注无数据源，只做展示 |
| 消息 | `layout_user_message.xml` + `item_user_message.xml` + `item_system_message_header.xml` | 完成 | 清空是本地操作；无 IM 长连接 |
| 订单列表 | `activity_my_order.xml` + `fragment_my_activity_order.xml` + `item_order_ticket.xml` | 完成（企划 Tab） | 「商品」Tab 是显式空状态；「待评论」用 `completed` 近似 |
| 我的 | `layout_user.xml` + `view_user_info.xml` + `view_user_order.xml` + `view_user_menu.xml` | 完成 | 粉色「想看」卡无数据源，去掉；兜礼/等级为演示值 |
| 演出详情 | `layout_show_detail.xml` + 5 个 `view_show_detail_*.xml` | 完成 | 选座/代抢/拼团/求票/粉丝社区/评价/资讯不做 |
| 登录注册 | `layout_login_register.xml` | 完成（**已接真实接口**） | 微信登录未接 SDK；图形验证码改成按需弹框（来源是内联一行） |
| 确认订单 | 既有实现 | **未改动** | 上一轮 DDD 交付时已完成 |

验证：`flutter analyze lib test tool packages/infras/core/lib` 无问题；`flutter test` **202 passed**。
新增两条测试：

- `test/features/pages_smoke_test.dart`——每个页面在 360dp / 320dp 两档窄屏各渲染一次，
  只断言"首帧不抛异常、不溢出"；
- `test/features/auth/login_page_test.dart`——7 条，覆盖模式切换、校验、协议门禁、来源页回跳。

> 冒烟测试抓到了 2 处真实溢出（都在 360dp 就溢出，不是极端屏才有的问题）：
> `ShowCardFloor` 的「价格 + 折扣标签」在 76dp 卡里溢出 19px；
> `OrderListCard` 底部「共 N 张 实付 + 金额 + 状态按钮」在部分状态下溢出 8~21px。
> 两处都改成可收缩（`Flexible` / `FittedBox.scaleDown`）而不是截断——来源侧是
> 固定宽度 `LinearLayout`，超出部分是**直接裁掉**的，等比缩小比裁掉更接近观感。
> 修完在 320dp 下也干净。

## 1. 新增的两层公共代码

页面之前先补了两个被多页复用的层，否则每个页面都要重抄一遍卡片。

- `lib/shared/ui/`：**与业务无关**的表现层（`ps_poster` / `ps_price` / `ps_tag` /
  `ps_section_header` / `ps_cell` / `ps_badge` / `ps_empty_state` /
  `ps_shortcut_grid` / `ps_search_bar`）。硬约束：这一层**不 import `features/`**。
- `lib/features/catalog/`：演出数据域（`ShowSummary` / `ShowCategory` / `VenueSummary` +
  `demo_catalog` 约 30 场演出 / `catalog_providers` / `ui/show_cards`）。
  首页、详情、发现三个页面共用同一份数据，避免三套假数据互相打脸。

### 资源策略（影响全部页面）

本地 `assets/` 已整体移除，不再打包任何图片 / 动画 / 字体。所以：

- 海报、头像走 `PsPoster` / `PsImages`，用开源免费图床（Lorem Picsum，
  图片来自 Unsplash）的确定性 seed URL，网络失败回落渐变 + 首字水印；
- 业务图标全量改用 `LucideIcons`（`lucide_icons_flutter`），不再使用 Material `Icons.*`；
- 分类与 API 配置由 `demo_categories.dart` / `api_config.dart` 的编译期常量提供，
  不再运行时读 `assets/**.json`；
- 品牌字体 DIN 移除，数字改用系统默认字体 + 等宽数字特性；
- 底部 Tab 的 Lottie 动画与首页加载动画改为代码绘制（Lucide 图标 /
  `CircularProgressIndicator`）。

## 2. 逐页说明

### 首页 `home_page.dart`

`CustomScrollView` + 吸顶 `HomeHeader`（`SliverPersistentHeader`，max/min extent
按 `view_home_header.xml` 的 22dp logo + 36dp 搜索框 + 间距算出，logo 随滚动淡出、
搜索框上移、底部 1dp 分隔线淡入）。

已实现的楼层（顺序即 `HomeMultiAdapter` 的注册顺序）：
`Header` → `Shortcut`（`view_home_icon` 5×2 分页，20×4 指示器，12dp 选中条）→
`Banner`（80dp、圆角 12、4s 自动轮播）→ `Guarantee`（26dp，最多 4 项，1dp 竖线分隔）→
`Choiceness`（42dp 滚动 Tab，选中 16sp 粗体 `text_0` / 未选中 14sp `text_2`，
这组值是 `HomeChoicenessView.onTabSelected/Unselected` 里写死的，**不是**布局里的）→
`HomeShows`（4 个分类楼层：演唱会/话剧/交响/儿童剧）→ `PopularVenues`（268dp 卡，
0.5dp 分隔线，两张 115dp 小卡）→ 页脚 logo。

**没做**：`OpProvider` / `CenterOpProvider` / `ThemeRecommendProvider` /
`HomeWaterfallProvider` / `ActorsProvider` / `RecommendWordProvider` /
`HomeHotTourProvider` / `HomeHotActorSiteProvider` / `HomeRecommendProvider` /
`EmptyItemProvider`。理由统一：这些楼层**没有固定布局**，全部由运营接口下发
`ViewType` + `schema` 拼装，没有接口就没有可对齐的 UI；硬造会得到一堆
"看起来像但永远不对"的占位。城市无数据时给 `PsEmptyState` + 一键切上海。

### 发现 `discover_page.dart`

`fragment_discovery.xml`：`#FFFCFCFC` 浅底、44dp 顶栏（居中 17sp 粗体
`热门 / 关注`、左侧 50dp 搜索、3dp 投影）、双列瀑布流（按奇偶拆成两个 `Column`，
10dp 间距）、右下 42dp 渐变发布按钮。

动态卡对齐 `item_discovery_feed`：`#1C1C1E` 圆角 6、16:9 海报 + 32dp 底部黑渐变、
**压在图片下沿**的黄色 `#FFFFE600` 标签（`bottom: -8`）、白色 13sp 两行标题、
14dp 圆头像 + 10sp 作者 + 眼睛图标 + 阅读数（`1.2万` 口径）。

**差异**：动态详情页不存在（点击给提示）；`关注` Tab 返回**空状态**而不是伪造热门流
——没有社交图谱，伪造比空着更误导；点赞数只读（无 per-user 记录）；发布走本地
`FeedController.publish`，插入列表头部。

### 消息 `message_page.dart`

50dp 顶栏（居中 16sp「消息中心」，右侧 50×50 清空按钮，无数据时禁用）+ 1dp 分隔线 +
15dp 边距 + 113dp 圆角 12 三角色卡（56dp 图标、13sp 文案、18dp 角标平移 `-14/-4`）+
白色「仅上圆角 20」的会话列表（80dp 行、48dp 方头像圆角 4、16dp 标题、绝对定位的
11sp 时间、14sp `text_3` 单行摘要、1dp `#EEEEEE` 分隔线）。

**差异**：来源里标题左侧有个返回箭头，这里没有（消息已是外壳的 Tab，不是压栈页）；
清空只清本地 `MessageCenterController`；无 IM/推送，进入页面不会拉新消息。

### 订单列表 `order_list_page.dart`

40dp 一级 Tab（演出 16sp 粗体 `#FFFF2261` + 24×2dp 指示条 / 商品）+ 40dp 二级
`PagerSlidingTabStrip`（5 等分、14sp、选中加粗 + 24×2dp 指示条）+ `RefreshIndicator`。

订单卡严格按 `item_order_ticket.xml`：14dp 内边距、16sp 标题 + 代购小标签、
右对齐 12sp 状态（未付款用 `colors.price`）、58×76 海报、场次/票档×张数/观演人/订单号、
16dp 处 1dp 分隔线、46dp 底部行（`共 N 张 实付` + `PsPrice(size:16)` + 28dp 胶囊按钮）。
按钮按 7 种状态给出不同组合（去支付/取消订单/查看详情/确认收货/去评价/再次购买/联系客服），
待付款卡带**每卡独立**的 1s 倒计时，归零自动取消并显示「支付已超时，请重新下单」。

**差异**：

- 「商品」Tab 是显式空状态——本次只迁移了票务链路，商品订单聚合不存在，不造假数据；
- 来源的 `ReviewToDoListFragment`（待评论）在域里没有独立状态，用 `OrderStatus.completed`
  近似（`OrderListFilter.matches` 里就这一处近似，注释已标明）；
- 状态编码从三套（`OrderStatus` 1–7 / `OrderUtils` 0–7 / 列表 0–3）收敛成
  **一个域枚举 + 一个 `OrderListFilter`**，仓储端口只暴露 `findAll()`；
- 6 条演示订单由 `order_history_seed.dart` **驱动真实聚合**跑出来
  （create→submit→markPaid→markShipped→complete/cancel/refund），金额与状态自洽。

### 我的 `user_page.dart`

`#FFF5F5F5` 底、顶部 `#FFFFE4EE → bgPage` 渐变、45dp 图标行（设置 + 带角标的消息）、
103dp 白色圆角 14 资料卡（56dp 圆头像、14sp 昵称、18dp 等级胶囊、
`个人主页 ›`、底部 想看/关注 用 1×18dp 竖线分隔）、120dp 订单卡
（`margin: top 17 / left 8.5 / right 8.5`，`marginTop: 92dp` 与 `goneMarginTop: 17dp`
的切换在 Flutter 里等价于 `top: 17`，因为粉色卡已去掉）、66dp 资产卡、4 行 58dp 菜单、
登录/退出按钮、底部 66dp 占位（对应 `layout_user.xml` 的 `paddingBottom=66dp`）。

**差异**：`list_to_watch`（粉色渐变「想看」卡）在来源里默认 `gone` 且无数据源，去掉；
`兜礼` 标签、`V3 资深票友`、12 想看 / 38 关注 / 3 张券 / ¥128.50 都是演示常量；
订单角标复用 `orderStatusCountsProvider`，和订单页 Tab 天然一致。

### 演出详情 `goods/show_detail_page.dart`

`AdaptiveScaffold(body: Column[Expanded(CustomScrollView), _PurchaseBar])`：
`CollapsingToolbar` 语义用 `SliverPersistentHeader` 实现（max = 安全区 + 230，
min = 安全区 + 48），全幅海报 + `#8C000000` 遮罩 + 92×124 小海报 + 14sp 白色三行标题 +
`#FFFFB238` 评分 + 白色胶囊价格 + 20dp 白色上圆角内容页，返回/分享按钮随折叠淡出。
42dp 锚点 Tab（简介/票档/须知）用三个 `GlobalKey` + `Scrollable.ensureVisible` 定位。

区块：`header_other`（时长/状态/场馆/导航）→ `btnTicketSource`（34dp `#FFFFDAE9`
安心保障条）→ 票档行 → 阵容 → 简介 → 购票须知 → 服务保障（40×1dp 细线夹标题 + 4 个 30dp 图标）
→ 66dp 底部购买栏（客服 / 想看 / 46dp 圆角 25 购买按钮，售罄时 `brandDisabled` + 「暂时售罄」）。

**差异**：`选座` / `代抢` / `拼团` / `求票` 浮球 / `粉丝社区` / `评价` / `资讯` / `proxy_guide`
全部不做——它们各自是独立页面或第三方 SDK 流程，当前仓库没有对应聚合；
`expend_more` 的 300dp webview 简介换成原生文本展开。

### 登录注册 `auth/login_page.dart`

按 `layout_login_register.xml` 逐条实现：顶部 `#FFFFE9EF → #FFFFFFFF` 纵向渐变
（24dp 关闭按钮距顶 45dp、24dp 字标、24sp 粗体标题）→ 52dp 手机号行（带清除按钮）→
1dp 分隔线 → 52dp 验证码行（右侧 79×30「获取验证码」，14sp `#FFFF2261`，
不可用 alpha 0.5，60s 倒计时）→ 1dp 分隔线 → 48dp 登录按钮
（渐变 `#FFFF2661 → #FFFF5180`、圆角 8、16sp 粗体白字、不可用 alpha 0.3）→
36dp 协议行（14dp 勾选框 + `已阅读并同意《注册协议》和《隐私协议》`，
协议名 `text_0` 可点、说明 `text_3`，右侧「密码登录 / 验证码登录」切换）→
底部块（距屏底 64dp）：「更多登录方式」两侧细线 + 46dp 微信入口。

**差异**：

- 图形验证码 `lay_captcha` 来源默认 `gone`、风控时切 `visible`（内联一行）；
  这里做成**按需弹框**——风控是低频事件，为它长期占一行 40dp 不划算，
  且弹框能保证"不处理完就发不出去"，效果与来源一致；
- `btn_back` 也是 `gone`，只留关闭；关闭时若来源是门禁页（`/order`）则退首页，
  否则会被 redirect 再踢回登录页；
- 微信登录未集成 SDK，点击给提示；`icon_wechat` 未迁移，用微信绿块 + 矢量图标重绘；
- 协议页不存在，点击弹说明对话框；
- 登录成功写 `AuthController` 的会话后 `context.go(from)`，与门禁 redirect 配合。

**接口联调（本轮新增）**：这一页现在打的是真实接口，不是本地校验。

| 动作 | 接口 | 失败怎么显示 |
|---|---|---|
| 获取验证码 | `POST v3/user/sendLoginCode` | `errorMsg`（`发送失败` / `请输入图形验证码`） |
| 验证码登录 | `POST v1/user/login`（`code`） | 服务端 `text/plain` 原文（`验证码不正确`） |
| 密码登录 | `POST v1/user/login`（`pw`） | 服务端原文（无密码账号返回 `401`；演示账号 `13800000001 / 123456` 可用） |
| 图形验证码 | `GET v1/user/captcha` | 弹框内提示并可"换一张" |

- 风控要图形码时：弹框 → 用户输字符 → **用同一个请求体补 `captcha` 重放**，
  最多 3 轮（防服务端一直要码把用户困住）；
- 账号被锁定 → 不可取消的对话框（来源同）；
- 令牌 `psSession` 由拦截器从**响应头**抓，落 `SecureStore`（来源存明文 prefs）；
- 契约细节见 `docs/api-contract.md`，可执行验证见 `tool/verify_login_api.dart`。

**"我的"页跟着变**：`userProfileProvider` 改成读登录返回的 `user`——
昵称 / 头像 / 等级 / 想看数 / 关注数都是真值，头像为空或加载失败回落默认图。
券数与余额仍未接（要 `v1/coupon/count` / `v1/wallet/balance`），保持演示值。

## 3. 仍然存在的系统性差异

1. **文案已走 l10n**：`lib/l10n/arb/**` 按 13 个命名空间（app + 12 个 feature）
   拆分，共 922 条，`dart tool/gen_l10n.dart --check` 与 `lib/l10n/generated`
   完全一致；页面里的中文不再以字面量散落。
2. **网络层按域逐步接通**：`ApiClient`（基于 Dio、永不抛异常、统一
   `Result<T>`）、`PsNetworkInterceptor`（UA / `dvid` / `Cookie: psSession` /
   401 钩子）与 `ApiConfig` 已在 `lib/app/network/` 装配；默认真实接口，
   `--dart-define=PS_USE_DEMO=true` 回落演示数据。当前状态：
   - `auth`：`POST v3/user/sendLoginCode`、`POST v1/user/login`、`GET v1/user/captcha`；
   - `catalog`：`GET v1/projects/hot`、`GET v1/projects`（服务端分页 + 城市/分类过滤）、
     `GET v1/projects/{id}`、`GET v1/rankings`、`GET v1/home/banners`；
     列表页触底调用 `ShowCatalogController.loadMore()` 追加下一页；
   - `order`：列表/详情/确认/下单、`POST/GET v1/order/{id}/refund`、
     `POST v1/unifiedPay/pay` 与 `GET v1/unifiedPay/payDetail` 全部走真实接口
     （`Idempotency-Key` + 报价快照）；取消、确认收货等写操作在本批契约外，
     真实模式明确提示"暂不支持"；
   - `user`：资料与收货地址走真实接口；券、余额等仍为演示值；
   - `discover`：热门/关注流走 `GET v4/feed/hot`、`GET v1/feed`，详情
     `GET v1/tweets/{id}`，评论 `GET v1/userReply?tweetId=`；详情查不到时回
     「动态不存在」空态，评论失败按「暂无评论」降级，不阻断正文；
   - `message`：`GET v1/messages?type=1/2/3` 分别拉三类通知并累加未读，组成
     三个系统入口（活动通知 / 回复我的 / 赞和关注）；入口点击走
     `POST v1/messages/read` 逐条标已读；「我的」页角标走
     `GET v1/messages/unreadCount`。会话列表走 `GET v1/chat/threads`，会话页
     `GET/POST /v1/chat/threads/{id}/messages` 收发、`POST .../read` 标已读；
   - `proxy_buy` / `group_buy`：已按 `ui / application / domain / data` 四层拆分，
     真实模式调用 `v1/proxyBuyOrder/myOrders`、`v1/pinTuanOrder/*`、
     `v1/pinTuanCampaign/{id}`。这 4 条是来源 Android 的遗留路径，**当前后端未注册**，
     真实模式会返回 404（演示模式不受影响）。

   后端当前注册 **46 条路由 / 45 个唯一端点**（`GET /v1/user/` 是 `GET /v1/user`
   的尾斜杠别名）。客户端 `ApiPaths.all` 共 33 条，由
   `test/api_paths_test.dart` 锁定；其中 29 条在后端有对应注册。逐端点对照见
   [api-contract.md](api-contract.md) §5。

   分页：企划列表已接服务端分页（触底 `loadMore`）；动态、消息、订单列表
   仍是一次性取全量，参数已写进 API 类，UI 尚未接翻页。消息与动态页已有
   `invalidate` 重试按钮，其余页面失败仍是 `AsyncValue.error` 直出；
   `core` 内已有 `RetryInterceptor`，但 `dioProvider`
   当前未挂载它。跑 `dart run tool/verify_catalog_api.dart --base=<host>` 可对真实
   后端做契约自检（列表/分页/详情/城市过滤/榜单/热门/Banner）。
3. **图片是占位**：见 §1，海报与分类图标没有真实资源。
4. **仍需补齐的独立页面**：评价、粉丝社区、资讯、个人主页、商品订单尚未迁移
   （完整清单见 [unimplemented-modules.md](unimplemented-modules.md) §1）。
   `feed_detail_page.dart` 已支持 B 站视频双通道（应用内播放 / 打开哔哩哔哩）；
   `chat_page.dart` 已接真实会话接口；`settings_page.dart` 部分入口为占位；
   `pay_page.dart` 走服务端支付单 + 轮询，仍未调起第三方 SDK；
   `seat_selection_page.dart` 有本地锁座 / 连座 / mm:ss 倒计时，座位图与库存仍由本地
   `demo_seat_map.dart` 生成。详见
   [unimplemented-modules.md](unimplemented-modules.md) §2.1/§2.2/§2.7。

## 4. 订单 / 个人中心企划化：文案保留例外

订单与个人中心已按企划语义改写（支持人、回报档位、支持份数、支持金额、预计交付时间、
支持编号）；本轮又把 `app` / `auth` / `catalog` / `discover` / `goods` / `group_buy` /
`home` / `marketing` / `message` / `order` / `proxy_buy` 的 ARB 与 Dart 硬编码字符串
统一为企划口径（演出→企划、票档→回报档位、购票/售票→支持、艺人→创作者、
剧院/场馆→活动场地、演唱会→音乐影像企划、代抢→代购、抢票→代购、开票→开放支持）。
`order_zh.arb` / `user_zh.arb` 中「演出|票档|座位|观演」已清零。

**例外清单（`tool/check_forbidden_terms.dart` 的结果）**：

- `goods_zh.arb` `chooseTicketPage_100` / `chooseTicketPage_109`「选择线下回报场次」
  （英文 `Select offline reward session`）——线下回报场次型企划必须按场次选择。
- `order_zh.arb` `refundState_11_2`「买错了线下回报场次或回报档位」
  （英文 `Selected the wrong offline reward session or reward tier`）——退款原因针对
  线下回报场次型企划。
- `lib/features/catalog/data/demo_catalog.dart:595`「线下点映城市取决于支持者分布，
  具体场次将提前公告。」——线下点映（线下回报）语境。
- 「商品」一级 Tab 及空态 `orderListPage_130`「暂无商品订单」——商品订单尚未迁移，
  按需求保留该分类，不并入企划（不含禁词，仅作说明）。

上述「场次」全部满足脚本的**线下上下文豁免**规则（同行含「线下」），因此
`tool/forbidden_terms_whitelist.json` 仍为空数组（0 条白名单），没有为了让检查通过而
放宽任何条目。检查脚本扫描 `lib/**/*.dart` 与 `lib/l10n/arb/**/*.arb`，命中
`演出|观演|票档|抢票|开票|门票|剧院|演唱会|艺人` 以及非线下语境的「场次 / 座位」即失败；
CI 在 l10n 校验之后运行 `dart tool/check_forbidden_terms.dart`。

场次信息的展示是**按回报档位类型收敛**的：仅当档位 `rewardType == '线下参与'` 时，
订单卡片、订单详情与选档页才展示场次 / 座席与选座入口；其余企划一律改为展示
「预计交付时间」（档位 `estimatedDeliveryTime` 优先，其次企划 `deliveryPlan`）、
回报档位、支持人、支持编号，不再出现票务字段。

