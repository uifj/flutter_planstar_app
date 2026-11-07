# 前端接口契约（客户端视角）

> 适用版本：planstar Flutter 9.9.39 · 最后核对：2026-11-07 · 维护：客户端组

> **事实源**：后端接口的唯一事实源是
> `planstar_kratos_server/docs/api/API_CONTRACT.md`（路由、字段、表映射以它为准）。
> 本文只记录**客户端如何调用、如何解析、当前接到哪一步**；与 `lib/` 冲突时，
> 以实现为准并修正本文。登录域的实现细节来自 2026-11 的真实请求
> （`dart run tool/verify_login_api.dart`），不是从反编译代码推断。

## 1. 基址与环境

| 环境 | Base URL | 说明 |
| --- | --- | --- |
| prod | `https://api.planstar.com/` | **占位域名**，当前不可用 |
| beta | `http://apibeta.planstar.com/` | 明文 HTTP，仅调试；同样是占位域名 |
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
| `User-Agent` | 是 | `PlanstarApi (com.planstar.app/9.9.39 Xiaomi developer-default Android/14)` |
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

**过渡期兼容**（登录域历史行为，必须保留）：

- `POST v1/user/login` 失败：`4xx/5xx` + `Content-Type: text/plain`，正文即用户文案
  （如「验证码不正确」）；客户端同时支持 JSON `message` 与纯文本正文。
- `POST v3/user/sendLoginCode`：**始终 HTTP 200**，用 body 里的 `success` /
  `needCaptcha` / `errorMsg` 表达结果。
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
| 演出库 `v1/activities*` | `page` / `pageSize` | 1 / 20 | 裸数组 |
| 动态 `v4/feed/hot`、`v1/feed` | `page` / `pageSize` / `nextPageKey?` | 1 / 20 | 裸数组 或 `{data, hasMore, nextPageKey}` |
| 消息 `v1/messages` | `pageIndex` / `pageSize` | 1 / 20 | 裸数组 或 `{data: [...]}` |
| 订单 `v1/order/list` | `pageIndex` / `pageSize` | 1 / 20 | 裸数组 或 `{data/list: [...]}` |

> 参数名不统一是后端现状，客户端已分别适配。演出库列表已接服务端分页
> （`ShowCatalogController.loadMore`，触底追加）；动态、消息、订单列表仍是
> 一次性取全量——后端支持翻页，UI 尚未接。

## 5. 端点清单与接入状态

后端 `internal/service/service.go` 当前注册 **24 条路由 / 23 个唯一端点**
（`GET /v1/user/` 是 `GET /v1/user` 的别名）。客户端 **23 个已全部接通**，
`lib/app/network/api_paths.dart` 是唯一路径清单，`test/api_paths_test.dart`
逐条锁定，多一条少一条都会失败。

### 5.1 已接（真实请求）

| # | 方法 | 路径 | 用途 | 客户端消费方 |
| --- | --- | --- | --- | --- |
| 1 | POST | `v1/user/login` | 验证码 / 密码登录 | `auth/login_page.dart` |
| 2 | POST | `v3/user/sendLoginCode` | 发送登录验证码 | 同上 |
| 3 | GET | `v1/user/captcha` | 图形验证码 PNG | 同上（按需弹框） |
| 4 | GET | `v1/home/banners` | 首页 Banner | `homeBannersProvider` |
| 5 | GET | `v1/activities/hot` | 热门演出 | `hotShowsProvider` |
| 6 | GET | `v1/activities` | 演出列表 / 城市 / 分类 | `showCatalogProvider`（含分页） |
| 7 | GET | `v3/activities/{id}` | 演出详情 | `showDetailProvider` |
| 8 | GET | `v4/feed/hot` | 热门动态 | `FeedController` |
| 9 | GET | `v1/feed` | 关注动态 | `followingFeedProvider` |
| 10 | GET | `v1/tweets/{id}` | 动态详情 | `feedPostByIdProvider` |
| 11 | GET | `v1/userReply` | 评论列表 | `feedCommentsProvider` |
| 12 | GET | `v1/messages` | 消息列表（按 `type` 取三类通知） | `MessageCenterController` |
| 13 | GET | `v1/messages/unreadCount` | 未读总数 | `messageUnreadProvider`（「我的」页角标） |
| 14 | POST | `v1/messages/read` | 标记已读 | `MessageCenterController.markEntryRead` |
| 15 | GET | `v1/order/list` | 订单列表 | `order_list_controller.dart` |
| 16 | GET | `v1/order/detail` | 订单详情 | 同上 |
| 17 | POST | `v1/unifiedOrder/confirm` | 订单确认 / 报价 | `order_confirm_controller.dart` |
| 18 | POST | `v3/unifiedOrder/makeOrder` | 下单（带 `Idempotency-Key`） | 同上 |
| 19 | GET | `v1/user` | 个人资料 | `remoteProfileProvider` |
| 20 | GET | `v1/myaddress` | 地址列表 | `addressListProvider` |
| 21 | POST | `v1/myaddress` | 新增地址 | 同上 |
| 22 | DELETE | `v1/myaddress/{id}` | 删除地址 | 同上 |
| 23 | POST | `v1/myaddress/default/{id}` | 设默认地址 | 同上 |

演示回落：以上全部在 `--dart-define=PS_USE_DEMO=true` 时改读本地演示数据
（`useDemoProvider` 分支），无需后端即可跑通页面与测试。

### 5.2 后端未实现（客户端不封装）

以下端点只存在于来源 Android 工程，本后端没有注册，客户端**不造接口**：

| 路径 | 来源能力 | 客户端现状 |
| --- | --- | --- |
| `POST/DELETE v1/userLike` | 点赞 / 取消赞 | 只读展示，无点赞写入 |
| `POST v1/userReply` | 发评论 | 评论只读 |
| `DELETE v1/messages/{id}` | 删除消息 | 清空为本地操作 |
| `GET v1/user/users`、`PUT v1/user/baseInfo` | 批量用户 / 改资料 | 编辑资料页不提交 |
| `POST v1/feed/publish` | 发布动态 | 本地插入，刷新即消失 |
| `GET v1/unifiedPay/payDetail`、`POST v1/unifiedPay/pay` | 支付 | 支付页本地模拟 |
| `v1/user/info`、`v1/coupon/count`、`v1/wallet/balance` | 资料统计 | 用登录态 + 演示值 |

### 5.3 已有页面但接口未封装（本地模拟）

以下能力后端没有端点，客户端**固定走本地 mock**（不受 `PS_USE_DEMO` 影响，
切真实环境也不会发请求）：

| 能力 | 页面 | 缺少的接口 |
| --- | --- | --- |
| 支付 | `lib/features/order/payment/pay_page.dart` | `v1/unifiedPay/payDetail`、`v1/unifiedPay/pay` |
| 选座 | `lib/features/goods/seatmap/seat_selection_page.dart` | 座位图、库存校验 / 锁座接口（当前 `demo_seat_map.dart`） |
| 优惠券 / 礼品卡 / 钱包 / 退款 | `lib/features/marketing/*`、`lib/features/order/refund/refund_page.dart` | 对应 `v1/coupon/*`、`v1/giftcard/*`、`v1/wallet/*`、退款接口 |
| 代抢 / 拼团 | `lib/features/proxy_buy/*`、`lib/features/group_buy/*` | 活动数据、下单与支付接口 |

## 6. 登录域实测细节

### 6.1 提交登录

```http
POST /v1/user/login
Content-Type: application/json

{"ua":"13800138000","code":"123456","ct":11}
{"ua":"13800138000","pw":"a1234567","ct":11}
{"ua":"13800138000","code":"123456","captcha":"ab3d","ct":11}
```

- 成功：`200` + 裸 `LoginBean`（不是 `{code,message,data}` 信封）；
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
（演示账号 `13800000001 / 123456` 实测 `200`），无密码的账号返回 `401`。
客户端保留密码/验证码两种入口，失败时如实展示服务端原文，不自造文案。

## 7. 验证方式

```bash
# 登录失败路径（无需验证码，可进 CI）
dart run tool/verify_login_api.dart

# 完整成功路径：在真机收一次验证码后填入
dart run tool/verify_login_api.dart --phone=13800001234 --code=123456

# 演出库契约自检（列表/分页/详情/城市过滤/热门/Banner）
dart run tool/verify_catalog_api.dart --base=http://127.0.0.1:8098/
```

2026-11-07 对本地后端做过一次全端点运行态核对：23 个唯一端点 + `v1/user/`
别名共 24 次请求全部符合预期（含登录、资料、地址增删改默认、消息未读与
标记已读、订单列表/详情、报价与下单），失败 0 条。

## 8. 客户端已知差异（刻意）

1. **不发明文 `psSession`**：来源存 `SharedPreferences`，这里存安全存储。
2. **不发 `channelAttributeInfo`**：广告归因字段，不影响鉴权。
3. **没有 `/logout` 接口**：服务端 `psSession` 自然过期，客户端只清本地会话。
4. **图形验证码做成按需弹框**：来源是默认 `gone` 的内联行，低频事件不长期占位。
5. **默认信封是 `PassthroughEnvelope`**：后端多数接口返回裸模型 + HTTP 状态码；
   若后端切换为 `{code,message,data}` 信封，需要同步改为 `RestCodeEnvelope`。
