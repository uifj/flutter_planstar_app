# 界面截图画廊（逐页）

> 采集环境：Xiaomi 23127PN0CC 真机 · Android 16 · 1200×2670 · 应用语言 `zh-CN` ·
> 客户端 debug 包 `1.0.1+1001` · 后端为本机 Docker `docker-compose.local.yml`
> （MySQL 8.4.13 + Redis 7 + `planstar-api:local`，业务端口 8098，`adb reverse tcp:8098`）·
> 采集日期 2026-11-16。
>
> 画面中的业务数据全部来自后端仓库的真实种子（`planstar_kratos_server/docs/sql/00_all.sql`、
> `planstar_kratos_server/docs/sql/14_mock_seed.sql` 与 `planstar_kratos_server/planstar/sql/15–20`），
> **不是设计稿、不是 `PS_USE_DEMO` 假数据**。请求实际打到
> `http://127.0.0.1:8098/v1/...`（真机经 `adb reverse` 回环到宿主机）。
>
> 本机 ROM 忽略 AOSP SystemUI demo 广播，截图中的状态栏时间 / 电量为系统真实值；
> 采集前临时关闭了第三方通知横幅，未对页面内容做任何修饰。截图不含任何明文手机号或口令：
> 登录页采的是空表单，设置页手机号由应用自身脱敏为 `138****0001`。

## 页面清单

路由列给出 `lib/app/router.dart` 中的注册行号；嵌套子路由以父路由 + 相对路径表示。

| # | 页面 | 路由（router.dart） | 截图 | 画面要点 |
| --- | --- | --- | --- | --- |
| 01 | 首页 | `/`（:140） | [01-home.png](01-home.png) | 分类 / 排行 / 精品 / 新企划 / 已达成五个快捷入口、保障条、运营位 Banner 兜底、精选推荐分类横滑、正在支持的企划横滑、已达成楼层、全部企划左图右文列表（触底分页） |
| 02 | 发现 | `/discover`（:149） | [02-discover.png](02-discover.png) | 热门 / 关注双 Tab、视频动态瀑布流、作者与阅读数、发布悬浮入口 |
| 03 | 企划（星推官审批） | `/project-idea`（:160） | [03-project-idea.png](03-project-idea.png) | 核心机制：审批叠卡、支持 / 不支持、上滑跳过、支持计数 |
| 04 | 我的（未登录） | `/me`（:180） | [04-me.png](04-me.png) | 登录引导、我的支持四态、星币商城 / 钱包 / 礼品卡、每日签到 |
| 05 | 登录 / 注册 | `/login`（:203） | [05-login.png](05-login.png) | 验证码登录空表单、协议勾选、密码登录切换、微信登录入口 |
| 06 | 我的（已登录） | `/me`（:180） | [06-me-logged-in.png](06-me-logged-in.png) | 昵称与等级徽章、消息 / 设置入口、支持 / 关注计数、每日签到 |
| 07 | 我的钱包 | `/wallet`（:444） | [07-wallet.png](07-wallet.png) | 星币余额头部、交易记录空态 |
| 08 | 星币商城 | `/mall`（:450） | [08-mall.png](08-mall.png) | 余额卡、商品与 SKU 档位、余额不足时兑换禁用 |
| 09 | 消息中心 | `/message`（:191） | [09-message.png](09-message.png) | 活动通知 / 回复我的 / 赞和关注、会话列表与未读角标 |
| 10 | 我的支持（订单列表） | `/order`（:198） | [10-order-list.png](10-order-list.png) | 企划 / 商品双 Tab、五态筛选；本轮演示账号无订单，展示空态引导 |
| 11 | 设置 | `/settings`（:399） | [11-settings.png](11-settings.png) | 账号（手机号脱敏）、消息通知开关、帮助与反馈、关于与版本号 |
| 12 | 企划详情（立项后） | `/show/:showId`（:209） | [12-project-detail.png](12-project-detail.png) | 达成率与筹款额、回报档位（digital / physical）、交付时间、已结束状态下的支持按钮 |
| 13 | 创意详情（立项前） | `/project-idea` + `:ideaId`（:160/:165） | [13-project-idea-detail.png](13-project-idea-detail.png) | 「尚未立项」标记、支持率、意愿档位分布、审批理由入口 |
| 14 | 品类页 | `/categories`（:260）；`/category/:categoryId`（:239）为同组件带参入口 | [14-category.png](14-category.png) | 服务端下发的一级品类横滑 Tab（游戏 / 小说 / 同人 / 面经 / 桌游）、二级标签栏、城市与搜索入口、企划列表卡（创作者 / 支持人数 / 达成率 / 剩余天数） |
| 15 | 搜索 | `/search`（:297） | [15-search.png](15-search.png) | 搜索历史、猜你想搜热搜榜（热标与热度值） |
| 16 | 搜索结果 | `/search/result`（:291） | [16-search-result.png](16-search-result.png) | 全部 / 企划 / 动态计数 Tab、命中列表、查看全部 |
| 17 | 动态详情 | `/feed/:id`（:305） | [17-feed-detail.png](17-feed-detail.png) | 作者与阅读数、正文、点赞 / 评论 / 分享、评论空态 |
| 18 | 企划榜单 | `/ranking`（:265） | [18-ranking.png](18-ranking.png) | 热度榜 / 达成榜 / 冲刺榜切换、Top 10 排名与支持人数 |
| 19 | 已达成企划 | `/achieved`（:282） | [19-achieved.png](19-achieved.png) | 已达成计数、左图右文列表、达成率与「已结束」状态 |

## 如实保留的空态与未接入占位

- **07 / 10 / 17**：钱包交易记录、支持记录、评论均为真实空态（种子未造这几类数据），
  空态文案与引导按钮按设计渲染。
- **17** 的视频占位条「播放器尚未接入」是真实未接入状态，登记在
  [../unimplemented-modules.md](../unimplemented-modules.md)，不做掩饰。
- **01** 的运营位 Banner：种子库 `planstar_content.banner` 为 0 行，接口返回空数组，
  首页按 [../../lib/features/home/widgets/home_banner_floor.dart:19](../../lib/features/home/widgets/home_banner_floor.dart#L19)
  的约定走内置视觉兜底。
- **15** 的热搜词与 **16** 的搜索结果目前由客户端基于已加载数据生成，后端尚无
  `v1/search*` 端点，登记在 [../ADR/ADR-0002.md](../ADR/ADR-0002.md)。

## 未采集的路由

交易链路（`/order/confirm`、`/order/detail`、`/order/pay`、`/order/pay-success`、
`/order/refund`）会真实写入订单与支付单，为避免污染种子数据未采集；
`/show/:showId/choose-ticket`、`/show/:showId/seat-selection`、`/venue/:name`、
`/group-buy*`、`/proxy-buy` 属遗留票务语义（见后端 `docs/product/POSITIONING.md` §10），
其中 `/venue/:name`、`/group-buy*`、`/proxy-buy` 当前在应用内无入口，见
[../ADR/ADR-0008.md](../ADR/ADR-0008.md)；
`/splash`、`/shows`、`/featured`、`/new-projects`、`/cities`、`/address`、`/feedback`、
`/coupons*`、`/giftcards*`、`/me/edit-profile`、`/message/thread/:id`、`/bilibili/:bvid`
本轮未纳入画廊。

## 复现采集

```bash
# 1. 后端（后端仓库 planstar_kratos_server/planstar 下）
docker compose -f docker-compose.local.yml up -d --build

# 2. 客户端 debug 包（真机 arm64，指向本机 8098）
flutter build apk --debug --target-platform android-arm64 \
  --dart-define=PS_API_BASE=http://127.0.0.1:8098/
adb install -r -t build/app/outputs/flutter-apk/app-debug.apk
adb reverse tcp:8098 tcp:8098
adb shell am start -n com.planstar.app.debug/com.planstar.app.MainActivity

# 3. 应用语言切中文（Android 13+ 按应用语言，无需重启整机）
adb shell cmd locale set-app-locales com.planstar.app.debug --locales zh-CN

# 4. 状态栏 demo 模式（可选；本机 ROM 忽略该广播，仅部分生效）
adb shell settings put global sysui_demo_allowed 1
adb shell am broadcast -a com.android.systemui.demo -e command enter
adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941

# 5. 逐页截图：先落到设备再 pull（PowerShell 的 > 重定向会破坏二进制 PNG）
adb shell screencap -p /sdcard/s.png
adb pull /sdcard/s.png docs/screenshots/01-home.png
```

登录用演示账号在设备上手动输入（adb 键注入），**凭据不写入本仓库任何文件**；
演示账号与测试口令的说明见后端仓库 `.env.local.example`。
退出 demo 模式：`adb shell am broadcast -a com.android.systemui.demo -e command exit`。
