# 前端接口契约副本（仅前端差异）

> 适用版本：planstar Flutter 9.9.39 · 最后核对：2026-11-07 · 维护：客户端组

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
| 默认占位域名 | `https://api.planstar.com/`（**不可用**，必须覆盖） |

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
5. **分页**：`v1/activities*` / feed 用 `page`；`v1/messages` / `v1/order/list` 用
   `pageIndex`；响应可能是裸数组或 `{data/list, hasMore, nextPageKey}`。
6. **演示开关**：统一为 `--dart-define=PS_USE_DEMO=true`（`useDemoProvider`），
   默认真实接口；不再是写死的编译期常量。
7. **支付 / 选座**：页面已存在，但支付信息来自 `PayInfo.demo`、SDK 调用为本地模拟；
   选座数据来自 `demo_seat_map.dart`，无锁座与库存校验。

## 3. 客户端接入状态

| 域 | 端点 | 状态 |
| --- | --- | --- |
| 认证 | `POST v1/user/login`、`POST v3/user/sendLoginCode`、`GET v1/user/captcha` | **已接** |
| 演出库 | `v1/home/banners`、`v1/activities/hot`、`v1/activities`、`v3/activities/{id}` | **已接**（列表含分页 / 城市过滤） |
| 动态 | `v4/feed/hot`、`v1/feed`、`v1/tweets/{id}`、`v1/userReply` | **已接** |
| 消息 | `v1/messages`、`v1/messages/unreadCount`、`v1/messages/read` | **已接** |
| 订单 | `v1/order/list`、`v1/order/detail`、`v1/unifiedOrder/confirm`、`v3/unifiedOrder/makeOrder` | **已接** |
| 用户 / 地址 | `v1/user`、`v1/myaddress`（列表 / 新增 / 删除 / 设默认） | **已接** |
| 支付 | `v1/unifiedPay/payDetail`、`v1/unifiedPay/pay` | 后端未实现（支付页本地模拟） |

后端注册的 23 个唯一端点（`v1/user/` 尾斜杠为别名）已全部接通，逐条对照见
[`../api-contract.md`](../api-contract.md) §5。

客户端文件：`lib/features/auth/data/planstar_auth_api.dart`、以及
`lib/features/{catalog,discover,message,order,user}/data/planstar_*_api.dart`。

## 4. 详细说明去哪看

- 通用约定、错误体、金额、分页、端点明细：
  [`../api-contract.md`](../api-contract.md)
- 后端正本（字段、SQL 表映射、后端落地建议）：
  `planstar_kratos_server/docs/api/API_CONTRACT.md`
- 页面完成度：[`../page-parity.md`](../page-parity.md)
- 未实现清单：[`../unimplemented-modules.md`](../unimplemented-modules.md)
