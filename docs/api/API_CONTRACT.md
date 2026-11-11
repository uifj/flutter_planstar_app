# 前端接口契约副本（仅前端差异）

> 适用版本：planstar Flutter 1.0.1 · 最后核对：2026-11-11 · 维护：客户端组

> **正本不在这里**。后端接口的唯一事实源是：
> `planstar_kratos_server/docs/api/API_CONTRACT.md`（方法、路径、鉴权、请求/响应字段、
> 错误码、金额单位、表映射均以它为准）。
>
> 本文件是前端仓库的副本，只保留「客户端接线状态 + 前端实现差异 + 联调参数」，
> 避免两份契约互相抄写后产生矛盾。若与后端正本冲突，以后端正本为准；
> 若与 `lib/` 实现冲突，以 `lib/` 为准并修正本文。

## 1. 前端联调参数

| 项 | 值 |
| --- | --- |
| 本地后端基址 | `http://127.0.0.1:8098/` |
| Android 模拟器 | `http://10.0.2.2:8098/` |
| 真机 | `http://<局域网 IP>:8098/` |
| Base 覆盖 | `--dart-define=PS_API_BASE=http://10.0.2.2:8098/` |
| 环境覆盖 | `--dart-define=PS_API_ENV=prod` / `beta` |
| 请求日志 | `--dart-define=PS_HTTP_LOG=true`（默认关闭） |
| 默认域名 | prod `https://api.planstar.top/` / beta `http://apibeta.planstar.top/`（取自 `ApiConfig.prodBaseUrl` / `ApiConfig.betaBaseUrl`；beta 为**明文 HTTP**，仅调试） |

Base URL **必须以 `/` 结尾**；路径不带前导 `/`。

## 2. 前端差异说明

1. **会话**：登录响应头或 `Set-Cookie` 里的 `psSession` 都读；之后统一拼
   `Cookie: psSession=…`；HTTP 401 触发全局登出钩子。
2. **响应解析**：默认 `PassthroughEnvelope`，成功响应是裸对象/裸数组，不套
   `{code,message,data}`。若后端改为统一信封，前端需切换 `RestCodeEnvelope`。
3. **统一错误体**：目标为 HTTP 状态码 + `{"code","message","traceId"}`；
   登录域过渡期仍兼容 `text/plain` 正文；`v3/user/sendLoginCode` 例外地使用
   `200 + {success,needCaptcha,errorMsg}`。
4. **金额**：请求与响应都用整数分（`Money.minorUnits`）；下单金额以服务端重算为准，
   不一致返回 `409`。
5. **分页**：`v1/projects*` / feed 用 `page`；`v1/messages` / `v1/order/list` 用
   `pageIndex`；`v1/projectIdeas/feed` 用 `cursor` / `size`；
   `v1/chat/threads/{id}/messages` 用 `before` / `limit`；
   响应可能是裸数组或 `{data/list, hasMore, nextPageKey}`。
6. **演示开关**：统一为 `--dart-define=PS_USE_DEMO=true`（`useDemoProvider`），
   默认真实接口；不再是写死的编译期常量。
7. **支付**：真实模式走 `/v1/unifiedPay/*`——创建支付单后每 2 秒轮询 `payDetail`
   （截止 `expireAt`），只有第三方渠道 SDK 的调起仍是本地模拟。
8. **选座**：本地锁座 / 连座校验 / 倒计时已实现（`SeatLockService`，默认 TTL 10 分钟，
   只在当前进程内有效）；座位图与库存仍由 `demo_seat_map.dart` 生成，未接服务端。
   座位图按 POSITIONING.md §10 是线下回报场次的可选降级能力。

## 3. 客户端接入状态

| 域 | 端点 | 状态 |
| --- | --- | --- |
| 认证 | `POST v1/user/login`、`POST v3/user/sendLoginCode`、`GET v1/user/captcha` | **已接** |
| 企划库 | `v1/home/banners`、`v1/projects/hot`、`v1/projects`、`v1/projects/{id}`、`v1/rankings` | **已接**（列表含分页 / 分类 / 筹资状态 / 排序） |
| 企划创意 | `v1/projectIdeas/feed`、`v1/projectIdeas/{ideaId}`、`POST v1/projectIdeas/{ideaId}/vote` | **已接**（叠卡流游标翻页 + 支持 / 不支持表态） |
| 动态 | `v4/feed/hot`、`v1/feed`、`v1/tweets/{id}`、`v1/userReply` | **已接** |
| 消息 | `v1/messages`、`v1/messages/unreadCount`、`v1/messages/read` | **已接** |
| 会话 | `v1/chat/threads`、`GET/POST v1/chat/threads/{id}/messages`、`POST v1/chat/threads/{id}/read` | **已接**（无长连接与推送） |
| 订单 | `v1/order/list`、`v1/order/detail`、`v1/unifiedOrder/confirm`、`v3/unifiedOrder/makeOrder` | **已接** |
| 支付 | `POST v1/unifiedPay/pay`、`GET v1/unifiedPay/payDetail` | **已接**（创建支付单 + 轮询；未调起第三方 SDK） |
| 退款 | `POST/GET v1/order/{id}/refund` | **已接** |
| 用户 / 地址 | `v1/user`、`v1/myaddress`（列表 / 新增 / 删除 / 设默认） | **已接** |
| 星币钱包 / 签到 | `GET v1/moneyaccount`、`GET v1/moneyaccount/sequences`、`GET/POST v1/user/signIn` | **已接** |
| 星币商城 | `v1/shop/goods`、`v1/shop/goods/{id}`、`POST v1/shop/goods/{id}/skus/{skuId}/redeem` | **已接** |
| 遗留票务路径 | `v1/proxyBuyOrder/myOrders`、`v1/pinTuanOrder/myOrders`、`v1/pinTuanOrder/make`、`v1/pinTuanCampaign/{id}` | 后端未注册，真实模式 404；演示模式不受影响 |

后端注册 **56 条路由 / 55 个唯一端点**（`GET /v1/user/` 是 `GET /v1/user` 的别名）。
客户端 `ApiPaths.all` 共 **42 条路径**：**38 条**在后端有注册，**4 条**是上表的遗留
票务路径；后端另有 **12 条路径**客户端尚未调用。逐条对照见
[`../api-contract.md`](../api-contract.md) §5。

客户端文件：`lib/features/auth/data/planstar_auth_api.dart`、以及
`lib/features/{catalog,discover,message,order,user}/data/planstar_*_api.dart`；
另有 `lib/features/project_idea/data/project_idea_api.dart` 与
`lib/features/mall/data/mall_api.dart`。

## 4. 详细说明去哪看

- 通用约定、错误体、金额、分页、端点明细：
  [`../api-contract.md`](../api-contract.md)
- 后端正本（字段、SQL 表映射、后端落地建议）：
  `planstar_kratos_server/docs/api/API_CONTRACT.md`
- 页面完成度：[`../page-parity.md`](../page-parity.md)
- 未实现清单：[`../unimplemented-modules.md`](../unimplemented-modules.md)

