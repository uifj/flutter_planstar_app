# features/ 各页面完成情况

> 适用版本：planstar Flutter 1.0.1 · 最后核对：2026-11-11 · 维护：客户端组

> 口径：逐个页面核对**当前代码里的类文档注释**，尺寸/字号/颜色**不靠感觉**，
> 每处刻意取舍都在注释里写明了原因。本文件是那份注释的汇总，
> 用来回答"哪些做完了、哪些还差、为什么这么做"。
> 产品口径见 `planstar_kratos_server/docs/product/POSITIONING.md`：
> 决策项目叫「企划」，用户是「支持者」，投票审批的人是「星推官」。

## 0. 总览

| 页面 | 状态 | 主要差异 |
| --- | --- | --- |
| 首页 `home/home_page.dart` | 完成 | 运营位/瀑布流/推荐词等**服务端配置型**楼层不做 |
| 发现 `discover/discover_page.dart` | 完成 | 点赞/关注无 per-user 数据源，只做展示 |
| 消息 `message/message_page.dart` | 完成（个人中心二级页） | 清空是本地操作；无 IM 长连接 |
| 我的支持 `order/order_list_page.dart` | 完成（企划 Tab） | 「商品」Tab 是显式空状态；「待评价」用 `completed` 近似 |
| 我的 `user/user_page.dart` | 完成 | 「支持过清单」卡无数据源，去掉；券/余额为演示值 |
| 企划详情 `goods/show_detail_page.dart` | 完成 | 代抢/拼团/求票浮标不做；选座仅线下回报场次型企划 |
| 登录注册 `auth/login_page.dart` | 完成（**已接真实接口**） | 微信登录未接 SDK；图形验证码改成按需弹框 |
| 确认支持 `order/order_confirm_page.dart` | **未改动** | 上一轮 DDD 交付时已完成 |

验证（2026-11-11 实测）：`flutter analyze lib test packages/infras/core/lib` → No issues found；
`dart tool/gen_l10n.dart --check` → 14 套 / 996 条文案同步；`dart tool/check_forbidden_terms.dart` → 命中 0 处。
测试全绿，合计 **408 条**：

| 执行位置 | 命令 | 通过数 |
| --- | --- | --- |
| 仓库根 | `flutter test` | 253 |
| `packages/infras/core` | `flutter test` | 143 |
| `packages/infras/core_design_system` | `flutter test` | 12 |

> **CI 覆盖缺口**：`.github/workflows/ci.yml` 只跑仓库根的 `flutter test`，
> 上表后两行共 **155 条不在 CI 内**；`flutter analyze` 也只含 `infras/core/lib`，
> 不含 `core_design_system/lib`。CI 亦不跑 `build_runner`，生成物靠提交入库保证同步。
> 改这两个包时必须本地补跑，或另加 CI job。

两条关键测试：

- `test/features/pages_smoke_test.dart`——每个页面在 360dp / 320dp 两档窄屏各渲染一次，
  只断言"首帧不抛异常、不溢出"；
- `test/features/auth/login_page_test.dart`——7 条，覆盖模式切换、校验、协议门禁、门禁页回跳。

> 冒烟测试抓到了 2 处真实溢出（都在 360dp 就溢出，不是极端屏才有的问题）：
> `ShowCardFloor` 的「价格 + 折扣标签」在 76dp 卡里溢出 19px；
> `OrderListCard` 底部「共 N 份 实付 + 金额 + 状态按钮」在部分状态下溢出 8~21px。
> 两处都改成可收缩（`Flexible` / `FittedBox.scaleDown`）而不是截断——
> 等比缩小比直接裁掉更接近观感。修完在 320dp 下也干净。

## 1. 两层公共代码

页面之前先补了两个被多页复用的层，否则每个页面都要重抄一遍卡片。

- `lib/shared/ui/`：**与业务无关**的表现层（`ps_poster` / `ps_price` / `ps_tag` /
  `ps_section_header` / `ps_cell` / `ps_badge` / `ps_empty_state` /
  `ps_shortcut_grid` / `ps_search_bar` / `ps_network_images` / `ps_floating_tab_bar`）。
  硬约束：这一层**不 import `features/`**。
- `lib/features/catalog/`：企划数据域（`ShowSummary` / `ShowCategory` / `VenueSummary` +
  `demo_catalog` 21 个演示企划 / `catalog_providers` / `ui/show_cards`）。
  首页、详情、发现三个页面共用同一份数据，避免三套假数据互相打脸。
  类型名沿用 `Show*` 是历史命名，语义已是企划；改名要动 freezed 生成物与全部调用点，
  不在本轮范围。

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

### 首页 `home/home_page.dart`

`CustomScrollView` + 吸顶 `HomeHeader`（`SliverPersistentHeader`）：
展开高度 `topPadding + 78`（logo 行 22 + 间距 10 + 搜索栏 36 + 底部 6），
收起高度 `topPadding + 42`（搜索栏 36 + 上下 3）。logo 随滚动淡出并上移、
搜索框从 `top + 36` 上移到 `top + 3`、底部 1dp 分隔线淡入。

已实现的楼层（顺序即 `home_page.dart` 里的 sliver 顺序）：
`HomeHeader` → `PsShortcutGrid`（5×2 分页，20×4 指示器，12dp 选中滑块）→
`HomeBannerFloor`（80dp、圆角 12、4s 自动轮播）→
`HomeGuaranteeFloor`（26dp，最多 4 项，1dp 竖线分隔）→
`HomeChoicenessFloor`（42dp 滚动 Tab，选中 16sp 粗体 / 未选中 14sp，
这组值写在 `home_choiceness_floor.dart` 的 tab 构建里，**不是**主题里的）→
`HomeShowFloor`（热门企划，取前 8 条）→ `HomeRankingFloor`（榜单）→
`HomeShowFloor` × 4 个分类楼层（`_categoryFloorIds = [1, 2, 3, 4]`，
即游戏企划 / 小说企划 / 同人企划 / 面经企划）→ 页脚 logo。
`shows` 为空时整段换成 `PsEmptyState`：演示模式给一键切城市，真实模式只给空态。

**没做**：运营位、中心运营位、主题推荐、瀑布流、创作者列表、推荐词、
热门巡演、热门创作者站点、首页推荐、空占位这一批楼层。理由统一：
它们**没有固定布局**，全部由运营接口下发 `ViewType` + `schema` 拼装，
没有接口就没有可对齐的 UI；硬造会得到一堆"看起来像但永远不对"的占位。

### 发现 `discover/discover_page.dart`

`#FFFCFCFC` 浅底、44dp 顶栏（居中 17sp 粗体 `热门 / 关注`，靠**字色**区分选中、
无下划线；左侧 50dp 搜索、3dp 投影）、双列瀑布流（按奇偶拆成两个 `Column`，
10dp 间距）、右下 42dp 渐变发布按钮（右边距 11、下边距 14）。

没有引入 `flutter_staggered_grid_view`：卡片只有"标题 1 行 / 2 行"两种高度，
两列 `Column` 交替装填就能得到真正的瀑布流，且不增加依赖。

动态卡：`#1C1C1E` 圆角 6、16:9 海报 + 32dp 底部黑渐变、
**压在图片下沿**的黄色 `#FFFFE600` 标签（`bottom: -8`）、白色 13sp 两行标题、
14dp 圆头像 + 10sp 作者 + 眼睛图标 + 阅读数（`1.2万` 口径）。

**差异**：`关注` Tab 返回**空状态**而不是伪造热门流——没有社交图谱，
伪造比空着更误导；点赞数只读（无 per-user 记录）；发布走本地
`FeedController.publish`，插入列表头部。动态详情页已存在（见 §3.4）。

### 消息 `message/message_page.dart`

「我的 → 消息」的**二级页**，不是底部 Tab：50dp 顶栏（左侧返回箭头
`context.maybePop`、居中 16sp「消息中心」、右侧 50×50 清空按钮，无数据时禁用）+
1dp 分隔线 + 15dp 边距 + 113dp 圆角 12 三角色卡（56dp 图标、13sp 文案、
18dp 角标平移 `-14/-4`）+ 白色「仅上圆角 20」的会话列表（80dp 行、
48dp 方头像圆角 4、16dp 标题、绝对定位的 11sp 时间、14sp `text_3` 单行摘要、
1dp `#EEEEEE` 分隔线）。

**差异**：清空只清本地 `MessageCenterController`；无 IM/推送长连接，
进入页面不会自动拉新消息（会话收发走 HTTP，见 §3.2）。

### 我的支持 `order/order_list_page.dart`

「我的 → 订单」的**二级页**，顶栏有返回箭头（`context.maybePop`），返回回到个人中心。

40dp 一级 Tab（企划 16sp 粗体 `#FFFF2261` + 24×2dp 指示条 / 商品）+ 40dp 二级
状态 Tab（全部 / 待支付 / 众筹中 / 交付中 / 待评价，5 等分、14sp、
选中加粗 + 24×2dp 指示条）+ `RefreshIndicator`。

支持卡（`widgets/order_list_card.dart`）：14dp 内边距、16sp 标题 + 可选「代支持」小标签、
右对齐 12sp 状态（未付款用价格色）、58×76 海报、回报档位 × 份数 / 实名支持者 / 支持编号、
16dp 处 1dp 分隔线、46dp 底部行（`共 N 份 实付` + `PsPrice(size:16)` + 28dp 胶囊按钮）。
金额是刻意改动：「支持金额」几个字保持灰色，数字改用价格色 16sp 加粗——
支持卡上最该被一眼看到的数字就是金额，灰掉它是可读性问题。
按钮按状态给出不同组合（去支付/取消订单/查看详情/确认收到回报/去评价/再次支持/联系客服），
待付款卡带**每卡独立**的 1s 倒计时，归零自动取消并显示「支付已超时，请重新下单」。
倒计时放在卡里而不是列表页统一计时，否则整页每秒重建。

**差异**：

- 「商品」Tab 是显式空状态——商品（周边）订单聚合尚未迁移，不造假数据；
- 「待评价」在域里没有独立状态，用 `OrderStatus.completed` 近似
  （`OrderListFilter.matches` 里就这一处近似，注释已标明）；
- 状态编码从三套收敛成**一个域枚举 + 一个 `OrderListFilter`**，
  仓储端口只暴露 `findAll()`，筛选在应用层做——列表的 0–3 筛选码是第三套编码，
  不该污染仓储端口；
- 6 条演示订单由 `order_history_seed.dart` **驱动真实聚合**跑出来
  （create→submit→markPaid→markShipped→complete/cancel/refund），金额与状态自洽；
- 场次信息**按回报档位类型收敛**：仅 `rewardType == '线下参与'` 时展示场次 / 座席，
  其余企划展示「预计交付时间」（详见 §4）。

### 我的 `user/user_page.dart`

`#FFF5F5F5` 底、顶部品牌渐变（`brandSubtle → bgPage`，亮/暗主题自动适配）、
45dp 图标行（设置 + 带角标的消息）、103dp 白色圆角 12 资料卡
（56dp 圆头像 + 品牌光环、14sp 昵称、等级胶囊、底部「支持过 / 关注」两列
20sp 粗体数字 + 12sp 文案 + 1dp 竖线）、120dp 支持卡（「我的支持 / 全部支持」+
四个状态入口，26dp 图标 + 12sp 文案）、横向快捷区（星币商城 / 我的钱包 /
优惠券 / 礼品卡，24dp 品牌色图标）、每日签到卡、「更多服务」分组菜单
（地址 / 支持人 / 联系客服 / 卖家招募，58dp 行）、登录/退出按钮、
底部留白用 `PsFloatingTabBar.bottomClearance(context)`（胶囊净空 + 系统安全区），
不是写死的常量，否则滚到底时最后一屏会永久压在浮动 Tab 下。

**差异**：

- 支持卡**背后**那张粉色渐变「支持过清单」卡不做——没有"支持过"数据源，
  所以支持卡按紧凑上边距（间距令牌 16）渲染，而不是为了压在清单卡上再抬高一截；
- 资料卡右上角不放「个人主页」：没有落地页，做成死入口不如不做；
- 等级为空（`level == 0`）时用脱敏手机号占位；
- 昵称 / 头像 / 等级 / 支持过数 / 关注数读登录返回的真值；券数与余额仍是演示常量；
- 订单角标复用 `orderStatusCountsProvider`，和订单页 Tab 天然一致。

### 企划详情 `goods/show_detail_page.dart`

`AdaptiveScaffold(body: Column[Expanded(CustomScrollView), _PurchaseBar])`：
`CollapsingToolbar` 语义用 `SliverPersistentHeader` 实现（max = 安全区 + 230，
min = 安全区 + 48），全幅海报 + `#8C000000` 遮罩 + 92×124 小海报 + 14sp 白色三行标题 +
达成率与支持人数 + `#FFFFB238` 评分 + 白色胶囊价格 + 20dp 白色上圆角内容页，
返回/分享按钮随折叠淡出。
42dp 锚点 Tab（目标进度 / 回报档位 / 进度更新 / 风险说明）用 `GlobalKey` +
`Scrollable.ensureVisible` 定位。

区块顺序：目标进度 → 截止/交付信息 → 34dp `#FFFFDAE9` 支持保障条 → 回报档位 →
进度更新 → 风险说明 → 评价晒单（最近 3 条）→ 常见问题 → 举报入口（P2 风控）→
创作者信息 → 企划故事 → 支持须知 → 服务保障（40×1dp 细线夹标题 + 4 个 30dp 图标）
→ 46dp 底部支持栏（客服 / 关注 + 「支持此企划」，名额已满时 `brandDisabled` + 「暂时售罄」）。
企划故事用原生文本展开，不套 300dp webview。

**差异**：`代抢` / `拼团` / `求票浮球` 三个分支不做——它们属于旧票务叙事，
当前仓库没有对应聚合，且与「企划支持平台」定位冲突（代抢已下线，拼团降级为组队支持）。
`选座` 只对线下回报场次型企划保留，座位图与库存仍由本地 `demo_seat_map.dart` 生成。
评价晒单与常见问题已有展示区块，但写入口（发表评价 / 提交举报）当前是客户端演示反馈。

### 登录注册 `auth/login_page.dart`

顶部 `#FFFFE9EF → #FFFFFFFF` 纵向渐变（24dp 关闭按钮距顶 45dp、距左 20dp、
24dp 字标、24sp 粗体标题）→ 52dp 手机号行（带清除按钮）→ 1dp 分隔线 →
52dp 验证码行（右侧 79×30「获取验证码」，14sp `#FFFF2261`，不可用 alpha 0.5，
60s 倒计时；切到密码登录时换成密码行）→ 1dp 分隔线 → 48dp 登录按钮
（品牌色实底、圆角 8、16sp 粗体白字、不可用 alpha 0.3）→
36dp 协议行（14dp 勾选框 + `已阅读并同意《注册协议》和《隐私协议》`，
协议名 `textPrimary` 可点、说明 `textTertiary`，右侧「密码登录 / 验证码登录」切换）→
底部块（距屏底 64dp）：「更多登录方式」两侧细线 + 46dp 微信入口。

**差异**：

- 图形验证码做成**按需弹框**而不是常驻一行——`needCaptcha` 只在风控触发时出现，
  为它长期占一行 40dp 会让 99% 的用户看到一块空白；弹框还能保证
  "不处理完就发不出去"。图片是 `v1/user/captcha` 直接返回的 PNG 字节，
  用 `Image.memory` 渲染，不是 base64、不是 URL；
- 只保留关闭按钮，不做返回；关闭时若来源页是登录门禁页（`/order`）则退首页，
  否则会被 redirect 再踢回登录页；
- 「获取验证码」与「登录」按钮不可用时**仍然挂 onTap**（只降透明度）：
  挂 `null` 的话用户没填手机号点一下会毫无反应，看起来像页面卡住了；
- 微信登录未集成 SDK，点击给提示；微信图标用 Lucide 矢量重绘，尺寸仍是 46dp；
- 协议页不存在，点击弹说明对话框；
- 登录成功写 `AuthController` 的会话后 `context.go(from)`，与门禁 redirect 配合。

**接口联调**：这一页打的是真实接口，不是本地校验。页面自己**不发请求、不拼 token**，
只做三件事：表单校验、把失败翻译成 UI 动作、成功后导航。

| 动作 | 接口 | 失败怎么显示 |
|---|---|---|
| 获取验证码 | `POST v3/user/sendLoginCode` | `errorMsg`（`发送失败` / `请输入图形验证码`） |
| 验证码登录 | `POST v1/user/login`（`code`） | 服务端 `text/plain` 原文（`验证码不正确`） |
| 密码登录 | `POST v1/user/login`（`pw`） | 服务端原文（入口保留，但服务端当前已关闭密码登录） |
| 图形验证码 | `GET v1/user/captcha` | 弹框内提示并可"换一张" |

- 风控要图形码时：弹框 → 用户输字符 → **用同一个请求体补 `captcha` 重放**，
  最多 3 轮（防服务端一直要码把用户困住）；
- 账号被锁定 → 不可取消的对话框；
- 令牌 `psSession` 由拦截器从**响应头或 `Set-Cookie`** 抓，落 `SecureStore`
  （加密存储，不是明文 prefs）；
- 联调账号见后端 seed 数据，本仓库不写死任何手机号 / 密码；
- 契约细节见 `docs/api-contract.md`，可执行验证见 `tool/verify_login_api.dart`。

**"我的"页跟着变**：`userProfileProvider` 改成读登录返回的 `user`——
昵称 / 头像 / 等级 / 支持过数 / 关注数都是真值，头像为空或加载失败回落默认图。
券数与余额仍未接，保持演示值。

## 3. 仍然存在的系统性差异

1. **文案已走 l10n**：`lib/l10n/arb/**` 按 14 个命名空间（app + 13 个 feature）
   拆分，共 996 条，`dart tool/gen_l10n.dart --check` 与 `lib/l10n/generated`
   完全一致；页面里用扁平门面 `context.l10n.key` 取，中文不再以字面量散落。
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
     真实模式调用 `v1/proxyBuyOrder/myOrders`、`v1/pinTuanOrder/myOrders`、
     `v1/pinTuanOrder/make`、`v1/pinTuanCampaign/{id}`。这 4 条是**遗留票务路径**，
     当前后端未注册，真实模式会返回 404（演示模式不受影响）。代抢与「企划支持平台」
     定位冲突，待下线；拼团降级为组队支持。

   后端当前注册 **56 条路由 / 55 个唯一端点**（`GET /v1/user/` 是 `GET /v1/user`
   的尾斜杠别名）。客户端 `ApiPaths.all` 共 42 条，由
   `test/api_paths_test.dart` 锁定；其中 38 条在后端有对应注册，未注册的正是上面
   那 4 条遗留路径。逐端点对照见 [api-contract.md](api-contract.md) §5。

   分页：企划列表已接服务端分页（触底 `loadMore`）；动态、消息、订单列表
   仍是一次性取全量，参数已写进 API 类，UI 尚未接翻页。消息与动态页已有
   `invalidate` 重试按钮，其余页面失败仍是 `AsyncValue.error` 直出；
   `core` 内已有 `RetryInterceptor`，但 `dioProvider`
   当前未挂载它。跑 `dart run tool/verify_catalog_api.dart --base=<host>` 可对真实
   后端做契约自检（列表/分页/详情/城市过滤/榜单/热门/Banner）。
3. **图片是占位**：见 §1，海报与分类图标没有真实资源。
4. **仍需补齐的独立页面**：粉丝社区、资讯、个人主页、商品订单尚未迁移；
   评价只有详情页的展示区块，发表入口未接
   （完整清单见 [unimplemented-modules.md](unimplemented-modules.md) §1）。
   `feed_detail_page.dart` 已支持 B 站视频双通道（应用内播放 / 打开哔哩哔哩）；
   `chat_page.dart` 已接真实会话接口；`settings_page.dart` 部分入口为占位；
   `pay_page.dart` 走服务端支付单 + 每 2 秒轮询 `payDetail`（截止 `expireAt`），
   仍未调起第三方 SDK；`seat_selection_page.dart` 有本地锁座 / 连座 / mm:ss 倒计时
   （`SeatLockService` 用可注入时钟），座位图与库存仍由本地 `demo_seat_map.dart` 生成。
   详见 [unimplemented-modules.md](unimplemented-modules.md) §2.1/§2.2/§2.7。

## 4. 订单 / 个人中心企划化：文案保留例外

订单与个人中心已按企划语义改写（支持人、回报档位、支持份数、支持金额、预计交付时间、
支持编号）；`app` / `auth` / `catalog` / `discover` / `goods` / `group_buy` /
`home` / `marketing` / `message` / `order` / `proxy_buy` 的 ARB 与 Dart 硬编码字符串
已按 POSITIONING.md §10 统一为企划口径（演出→企划、票档→回报档位、购票/售票→支持、
艺人→创作者、剧院/场馆→活动场地、演唱会→音乐影像企划、开票→开放支持）。
`order_zh.arb` / `user_zh.arb` 中「演出|票档|座位|观演」已清零。

> **待产品确认的口径冲突**：`proxy_buy` 的 ARB 文案当前用「代购」（待代购 / 代购中 /
> 代购服务 / 我的代购订单），而 POSITIONING.md §10 把「代抢」标为 **—（下线）**，
> §9 品类黑名单又把「代购」列为无企划落地属性的禁止交易。三者不一致。
> 代码侧已按「遗留票务能力，待下线」标注（`proxy_buy/domain/proxy_buy.dart`、
> `proxy_buy/ui/proxy_buy_page.dart`、`app/router.dart`），但**文案值本轮不改**
> （超出「注释 + 文档 + ARB 元数据」范围）。去留定了之后需要同时改 ARB 与路由。

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
放宽任何条目。检查脚本扫描 `lib/**/*.dart` 的字符串字面量与 `lib/l10n/arb/**/*.arb`
的文案值（注释与 `@key` 元数据不算），命中
`演出|观演|票档|抢票|代抢|开票|门票|剧院|演唱会|艺人` 以及非线下语境的「场次 / 座位」
即失败；CI 在 l10n 校验之后运行 `dart tool/check_forbidden_terms.dart`。

场次信息的展示是**按回报档位类型收敛**的：仅当档位 `rewardType == '线下参与'` 时，
订单卡片、订单详情与选档页才展示场次 / 座席与选座入口；其余企划一律改为展示
「预计交付时间」（档位 `estimatedDeliveryTime` 优先，其次企划 `deliveryPlan`）、
回报档位、支持人、支持编号，不再出现票务字段。

