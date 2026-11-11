# 前端接口契约（客户端视角）

> 适用版本：planstar Flutter 1.0.1 · 最后核对：2026-11-11 · 维护：客户端组

> **事实源**：后端接口的唯一事实源是
> `planstar_kratos_server/docs/api/API_CONTRACT.md`（路由、字段、表映射以它为准）。
> 本文只记录**客户端如何调用、如何解析、当前接到哪一步**；与 `lib/` 冲突时，
> 以实现为准并修正本文。登录域的实现细节由真实请求核对
> （`dart run tool/verify_login_api.dart` 可复跑），不是静态推断。

## 1. 基址与环境

| 环境 | Base URL | 说明 |
| --- | --- | --- |
| prod | `https://api.planstar.top/` | 后端实际部署域名（`ApiConfig.prodBaseUrl`） |
| beta | `http://apibeta.planstar.top/` | 明文 HTTP，仅调试（`ApiConfig.betaBaseUrl`） |
| 本地后端 | `http://127.0.0.1:8098/` | 后端默认业务端口 |
| Android 模拟器 | `http://10.0.2.2:8098/` | 模拟器访问宿主机的固定地址 |
| 真机 | `http://<局域网 IP>:8098/` | 手机与电脑需在同一网段 |

- 默认值在 `lib/app/network/api_config.dart`，可用编译期参数覆盖（优先级：`--dart-define` > 默认值）：
  - `PS_API_ENV`：`prod` / `beta`；
  - `PS_API_BASE`：完整 base，**必须以 `/` 结尾**（客户端做 `base + path` 字符串拼接）；
  - `PS_HTTP_LOG`：`true` 时打印请求/响应体（默认关闭，避免会话与手机号进日志）。
- 连接 / 接收 / 发送超时均为 **20s**。
- 路径**不带前导 `/`**（如 `v1/user/login`）。

## 2. 请求头与会话

| 头 | 是否必带 | 说明 |
| --- | --- | --- |
| `User-Agent` | 是 | `PlanstarApi (com.planstar.app/1.0.1 Xiaomi developer-default Android/14)` |
| `dvid` | 有则带 | 设备标识，首次由服务端下发并持久化 |
| `Cookie: psSession=…` | 登录后必带 | 会话令牌，**不是** `Authorization: Bearer` |
| `X-Longitude` / `X-Latitude` | 已定位才带 | 经纬度均 `> 0` 时才发送 |

会话来源（`lib/app/network/ps_network_interceptor.dart`）：

- 登录成功后从**响应头** `psSession` 或 `Set-Cookie: psSession=…` 读取，两处都兼容；
- 后续请求统一拼 `Cookie: psSession=<value>`；
- 任意接口返回 **HTTP 401** 时触发 `onUnauthorized` 钩子（全局登出）；
- `dvid` 同样从响应头 / `Set-Cookie` 抓取并持久化。

## 3. 响应格式与统一错误体

客户端使用 `PassthroughEnvelope`：成功响应**直接返回业务对象**（裸数组或裸对象），
不解析 `{code, message, data}` 信封。

**目标错误契约（生产基线）**：所有失败响应使用 HTTP 状态码 + 统一 JSON：

```json
{"code": 409, "message": "价格已变化，请刷新后重试", "traceId": "0af7651916cd43dd"}
```

- `code`：业务或 HTTP 错误码；
- `message`：可直接展示给用户的中文；
- `traceId`：服务端追踪 ID，用于日志关联，**不展示给用户**；客户端当前尚未统一
  提取该字段（待接），排障时仍需从服务端日志按时间/路径反查；
- 不返回 SQL、堆栈或内部路径。

客户端状态码映射（`packages/infras/core/lib/src/network/api_client.dart`）：

| HTTP | `Failure.code` | 默认文案 |
| --- | --- | --- |
| 400 | `BAD_REQUEST` | 请求参数有误 |
| 401 | `UNAUTHORIZED` | 登录已失效（触发登出钩子） |
| 403 | `FORBIDDEN` | 没有访问权限 |
| 404 | `NOT_FOUND` | 资源不存在 |
| 409 | `CONFLICT` | 状态冲突，请刷新后重试 |
| 429 | `TOO_MANY_REQUESTS` | 操作过于频繁 |
| 5xx | `SERVER_ERROR` | 服务开小差了，请稍后重试 |

**过渡期兼容**（登录域历史行为，客户端必须保留）：

- `POST v1/user/login` 失败：`4xx/5xx` + 用户文案（如「验证码不正确」）。后端现已
  统一输出 JSON 错误体（`httpx.Error`），历史上的 `Content-Type: text/plain` 正文
  仍被客户端兼容：`ApiClient` 两种都解析，且服务端原文优先于本地兜底文案。
- `POST v3/user/sendLoginCode`：发送结果**恒 HTTP 200**，用 body 里的 `success` /
  `needCaptcha` / `errorMsg` 表达结果；**触发限流时返回 `429`（`RATE_LIMITED`）**，
  不走 200 信封。
- `GET v1/user/captcha`：`200` + `image/png` 原始字节。

## 4. 金额与分页

### 4.1 金额

- 接口**入参与出参统一为整数分**，例如 `12800` = ¥128.00；
- 客户端用 `Money.minorUnits`（int）承载，只在展示层除以 100；
- 下单相关字段（`payAmount` / `totalAmount` 等）**必须传分**，且以服务端重新计算为准：
  客户端金额只作展示与草稿，服务端报价不一致时返回 `409`（`PRICE_CHANGED`）；
- 后端不要输出带小数的元（如 `128.0`），避免浮点误差。

### 4.2 分页

| 接口族 | 分页参数 | 默认值 | 响应包装 |
| --- | --- | --- | --- |
| 企划库 `v1/projects*` | `page` / `pageSize` | 1 / 20 | 裸数组 |
| 榜单 `v1/rankings` | `type` / `categoryId` / `limit` | `hot` / — / 10 | `{items: [...]}` |
| 企划创意 `v1/projectIdeas/feed` | `cursor` / `size` | 空 / 10 | `{items, nextCursor, hasMore}`（兼容 `list/records/data`） |
| 动态 `v4/feed/hot`、`v1/feed` | `page` / `pageSize` / `nextPageKey?` | 1 / 20 | 裸数组 或 `{data, hasMore, nextPageKey}` |
| 消息 `v1/messages` | `pageIndex` / `pageSize` | 1 / 20 | 裸数组 或 `{data: [...]}` |
| 会话 `v1/chat/threads/{id}/messages` | `before` / `limit` | — / 20 | 裸数组 |
| 订单 `v1/order/list` | `pageIndex` / `pageSize` | 1 / 20 | 裸数组 或 `{data/list: [...]}` |

> 参数名不统一是后端现状，客户端已分别适配。企划库列表与企划创意叠卡流已接服务端
> 翻页（`ShowCatalogController.loadMore` 触底追加；叠卡流按 `nextCursor` 预取）；
> 动态、消息、订单列表仍是一次性取全量——后端支持翻页，UI 尚未接。

## 5. 端点清单与接入状态

后端 `internal/service/service.go` 当前注册 **56 条路由 / 55 个唯一端点**
（`GET /v1/user/` 是 `GET /v1/user` 的别名）。客户端 `ApiPaths.all` 共 **42 条路径**：
**38 条**在后端有注册（§5.1），**4 条**是遗留票务路径（§5.4）；后端另有
**12 条路径**客户端尚未调用（§5.5）。`lib/app/network/api_paths.dart` 是唯一路径清单，
`test/api_paths_test.dart` 以集合相等逐条锁定，多一条、少一条或重复都会失败。

计数口径与后端 `planstar/internal/server/routes_test.go` 的 `normalizeRoute` 一致：
补前导斜杠、去尾斜杠与查询串。客户端清单把动态段用示例 id `1` 展开，
下表按后端路由模板书写；一行对应一条客户端路径，同路径多方法合并写。

### 5.1 已接（真实请求）

| # | 方法 | 路径 | 用途 | 客户端消费方 |
| --- | --- | --- | --- | --- |
| 1 | GET | `v1/home/banners` | 首页 Banner | `homeBannersProvider` |
| 2 | GET | `v1/projects/hot` | 热门企划 | `hotShowsProvider` |
| 3 | GET | `v1/projects` | 企划列表 / 分类 / 筹资状态 / 排序 | `showCatalogProvider`（含分页） |
| 4 | GET | `v1/projects/{id}` | 企划详情（回报档位 / 线下回报场次） | `showDetailProvider` |
| 5 | GET | `v1/rankings` | 企划榜单（热度 / 达成 / 冲刺） | `projectRankingProvider` |
| 6 | GET | `v4/feed/hot` | 热门动态 | `FeedController` |
| 7 | GET | `v1/feed` | 关注动态 | `followingFeedProvider` |
| 8 | GET | `v1/userReply` | 评论列表 | `feedCommentsProvider` |
| 9 | GET | `v1/tweets/{id}` | 动态详情 | `feedPostByIdProvider` |
| 10 | GET | `v1/projectIdeas/feed` | 企划创意叠卡流（游标翻页） | `ProjectIdeaFeedController` |
| 11 | GET | `v1/projectIdeas/{ideaId}` | 创意详情（含我的表态） | `projectIdeaDetailProvider` |
| 12 | POST | `v1/projectIdeas/{ideaId}/vote` | 支持 / 不支持表态 | `ProjectIdeaVoteService` |
| 13 | GET | `v1/messages` | 消息列表（按 `type` 取三类通知） | `MessageCenterController` |
| 14 | GET | `v1/messages/unreadCount` | 未读总数 | `messageUnreadProvider`（「我的」页角标） |
| 15 | POST | `v1/messages/read` | 标记已读 | `MessageCenterController.markEntryRead` |
| 16 | GET | `v1/chat/threads` | 会话列表 | `MessageCenterController` |
| 17 | GET/POST | `v1/chat/threads/{id}/messages` | 拉取会话消息 / 发送消息 | `ChatMessagesController`（发送乐观上屏 + 失败回滚） |
| 18 | POST | `v1/chat/threads/{id}/read` | 会话标记已读 | `PlanstarChatApi.markRead` |
| 19 | GET | `v1/order/list` | 订单列表 | `order_list_controller.dart` |
| 20 | GET | `v1/order/detail` | 订单详情 | 同上 |
| 21 | POST | `v1/unifiedOrder/confirm` | 订单确认 / 报价 | `order_confirm_controller.dart` |
| 22 | POST | `v3/unifiedOrder/makeOrder` | 下单（带 `Idempotency-Key`） | 同上 |
| 23 | POST/GET | `v1/order/{id}/refund` | 申请退款 / 查询退款进度 | `RefundController` |
| 24 | POST | `v1/unifiedPay/pay` | 创建支付单 | `PayController` |
| 25 | GET | `v1/unifiedPay/payDetail` | 轮询支付状态（每 2 秒，截止 `expireAt`） | 同上 |
| 26 | GET | `v1/user` | 个人资料 | `remoteProfileProvider` |
| 27 | GET/POST | `v1/user/signIn` | 签到状态 / 提交签到 | `signInStatusProvider`、`SignInController` |
| 28 | GET/POST | `v1/myaddress` | 地址列表 / 新增地址 | `addressListProvider` |
| 29 | DELETE | `v1/myaddress/{id}` | 删除地址 | 同上 |
| 30 | POST | `v1/myaddress/default/{id}` | 设默认地址 | 同上 |
| 31 | GET | `v1/moneyaccount` | 星币账户余额 | `walletProvider` |
| 32 | GET | `v1/moneyaccount/sequences` | 星币流水 | 同上 |
| 33 | GET | `v1/shop/goods` | 星币商城商品列表 | `mallGoodsProvider` |
| 34 | GET | `v1/shop/goods/{id}` | 商品详情 | `PlanstarMallApi.fetchGoodsDetail` |
| 35 | POST | `v1/shop/goods/{id}/skus/{skuId}/redeem` | 星币兑换 | `MallController.redeem` |
| 36 | GET | `v1/user/captcha` | 图形验证码 PNG | `auth/login_page.dart`（按需弹框） |
| 37 | POST | `v3/user/sendLoginCode` | 发送登录验证码 | 同上 |
| 38 | POST | `v1/user/login` | 验证码 / 密码登录 | 同上 |

演示回落：除登录域（`v1/user/login`、`v3/user/sendLoginCode`、`v1/user/captcha`）
与企划创意三条端点外，以上都在 `--dart-define=PS_USE_DEMO=true` 时改读本地演示数据
（业务层统一走 `dataSourcePolicyProvider`，不直接读 `useDemoProvider`），
无需后端即可跑通页面与测试。登录与创意表态没有演示分支，始终发真实请求。

### 5.2 后端未注册（客户端不封装）

以下端点本后端没有注册，客户端**不造接口**：

| 路径 | 能力 | 客户端现状 |
| --- | --- | --- |
| `POST/DELETE v1/userLike` | 点赞 / 取消赞 | 只读展示，无点赞写入 |
| `POST v1/userReply` | 发评论 | 评论只读（`GET v1/userReply` 已接） |
| `DELETE v1/messages/{id}` | 删除消息 | 清空为本地操作 |
| `GET v1/user/users`、`PUT v1/user/baseInfo` | 批量用户 / 改资料 | 编辑资料页不提交 |
| `POST v1/feed/publish` | 发布动态 | 本地插入，刷新即消失 |
| `v1/user/info`、`v1/coupon/count` | 资料统计 / 可用券数量 | 用登录态 + 演示值 |
| `v1/coupon/*`、`v1/giftcard/*` | 优惠券 / 礼品卡 | 页面走本地演示数据 |

支付与星币钱包**不再属于本表**：`v1/unifiedPay/*` 与 `v1/moneyaccount*` 后端已注册、
客户端已接（§5.1）。

### 5.3 已有页面但数据仍是本地模拟

以下能力的页面已存在，但数据源固定在本地（不受 `PS_USE_DEMO` 影响，
切真实环境也不会发请求）：

| 能力 | 页面 | 缺少的接口 |
| --- | --- | --- |
| 选座 | `lib/features/goods/seatmap/seat_selection_page.dart` | 座位图数据、服务端锁座与库存校验（当前 `demo_seat_map.dart`） |
| 优惠券 / 礼品卡 | `lib/features/marketing/*` | 对应 `v1/coupon/*`、`v1/giftcard/*` |
| 代抢 / 组队支持 | `lib/features/proxy_buy/*`、`lib/features/group_buy/*` | 后端未注册的 4 条遗留路径，见 §5.4 |

选座的本地锁座 / 连座校验 / 倒计时**已实现**（`SeatLockService`），缺的是服务端座位图
与库存；座位图按 POSITIONING.md §10 是线下回报场次的可选降级能力。
支付、退款、星币钱包、星币商城已接真实接口（§5.1），不再属于本表。

### 5.4 客户端已封装但后端未注册（4 条遗留票务路径）

这 4 条在 `ApiPaths.all` 里，data 层也真的会发请求，但后端路由表没有它们：
**真实模式返回 404，演示模式不受影响**。代抢按 POSITIONING.md §10 待下线，
组队支持保留社交裂变、去掉票务心智。

| 路径 | 客户端消费方 |
| --- | --- |
| `v1/proxyBuyOrder/myOrders` | `lib/features/proxy_buy/data/proxy_buy_api.dart` |
| `v1/pinTuanOrder/myOrders` | `lib/features/group_buy/data/group_buy_api.dart` |
| `v1/pinTuanOrder/make` | 同上 |
| `v1/pinTuanCampaign/{id}` | 同上 |

### 5.5 后端已注册但客户端未调用（12 条路径）

| 路径 | 说明 |
| --- | --- |
| `GET v1/activities/hot`、`GET v1/activities`、`GET v3/activities/{id}` | 票务域活动接口，POSITIONING.md §12 兼容保留；客户端已切到 `v1/projects*` |
| `GET v1/projects/{id}/reward-tiers` | 回报档位；客户端目前从企划详情里取 |
| `GET v1/projects/{id}/updates` | 进度更新 |
| `GET v1/projects/{id}/faqs` | 常见问题 |
| `GET/POST v1/projects/{id}/reviews` | 企划评价（读 / 写） |
| `POST v1/projects/{id}/reports` | 举报 |
| `POST v1/projects/{id}/pledges` | 创建支持记录 |
| `GET v1/pledges`、`GET v1/pledges/{id}` | 支持记录列表 / 详情 |
| `GET v1/creators/{id}` | 创作者主页 |

这些端点**后端已存在**，客户端未封装不等于「后端未实现」；接入时以
`planstar_kratos_server/docs/api/API_CONTRACT.md` 的字段定义为准。

## 6. 登录域实测细节

### 6.1 提交登录

```http
POST /v1/user/login
Content-Type: application/json

{"ua":"13800138000","code":"123456","ct":11}
{"ua":"13800138000","pw":"a1234567","ct":11}
{"ua":"13800138000","code":"123456","captcha":"ab3d","ct":11}
```

- 成功：`200` + 裸登录响应对象（客户端解析为 `LoginResponseDto`，不套
  `{code,message,data}` 信封）；
- `needCaptcha=true` 时 `user` 为 `null`，客户端重新弹图形码并重放原请求；
- `ct` 固定 `11`（Android），服务端按它决定返回字段；
- 响应头 `psSession` 即会话令牌。

### 6.2 发送登录验证码

```http
POST /v3/user/sendLoginCode
Content-Type: application/json

{"ua":"13800138000"}
{"ua":"13800138000","captcha":"ab3d"}
```

成功 / 失败都是 `200`，靠 body 区分：

```json
{"success":true,"needCaptcha":false}
{"success":false,"needCaptcha":true,"errorMsg":"请输入图形验证码"}
{"success":false,"needCaptcha":true,"errorMsg":"图形验证码错误"}
{"success":false,"needCaptcha":false,"errorMsg":"发送失败"}
```

版本错位是现状：**发码在 `v3`，登录在 `v1`**，不要统一。

### 6.3 图形验证码

`GET /v1/user/captcha` → `200` + `image/png` 原始字节；**不返回 `Set-Cookie`**，
服务端按 `dvid` + IP 关联，所以客户端必须在整个流程中保持 `dvid` 不变。

风控流程：发码 → `needCaptcha:true` → 拉图 → 带 `captcha` 重放发码（最多 3 轮）。

### 6.4 密码登录

后端走 `user_info.password_hash` 校验：设置了密码的账号可用 `pw` 登录
（演示账号 `13800000001 / 123456`，哈希种子见后端 `planstar/sql/15_auth_support.sql`），
无密码的账号返回 `401`。
客户端保留密码/验证码两种入口，失败时如实展示服务端原文，不自造文案。

## 7. 验证方式

```bash
# 登录失败路径（无需验证码，可进 CI）
dart run tool/verify_login_api.dart

# 完整成功路径：在真机收一次验证码后填入
dart run tool/verify_login_api.dart --phone=13800001234 --code=123456

# 企划库契约自检（列表/分页/详情/榜单/热门/Banner）
dart run tool/verify_catalog_api.dart --base=http://127.0.0.1:8098/
```

这两个脚本是可复跑的运行态核对入口：登录域覆盖失败路径与成功路径，企划库覆盖
列表 / 分页 / 详情 / 榜单 / 热门 / Banner（检查项见 `tool/verify_catalog_api.dart`）。
全端点运行态核对需按 §5 的 55 个唯一端点重跑，本文不快照某一次运行的通过数。

## 8. 客户端已知差异（刻意）

1. **不发明文 `psSession`**：令牌存 `SecureStore`（Keystore/Keychain）密文，
   不落明文 prefs——否则 root 设备可以直接读走会话。
2. **不发 `channelAttributeInfo`**：广告归因字段，不影响鉴权。
3. **没有 `/logout` 接口**：服务端 `psSession` 自然过期，客户端只清本地会话。
4. **图形验证码做成按需弹框**：低频事件不长期占位，不做默认隐藏的内联行。
5. **默认信封是 `PassthroughEnvelope`**：后端多数接口返回裸模型 + HTTP 状态码；
   若后端切换为 `{code,message,data}` 信封，需要同步改为 `RestCodeEnvelope`。

