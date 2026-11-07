# planstar Flutter 文档索引

> 适用版本：planstar Flutter 9.9.39 · 最后核对：2026-11-07 · 维护：客户端组

本文件是 `flutter_piaoniu_app/docs/` 的唯一入口。先看这里，再按需跳转。

## 1. 权威性声明

- **代码优先**：文档与 `lib/` 实现冲突时，**一律以 `lib/` 为准**；文档随后修正，不允许反过来要求代码迁就旧文档。
- **接口以契约为准**：后端接口的唯一事实源是 `planstar_kratos_server/docs/api/API_CONTRACT.md`。本仓库的 `docs/api-contract.md` 与 `docs/api/API_CONTRACT.md` 只描述**客户端视角与差异**，不另立一套契约。
- **路由/开关以实现为准**：深链路由看 `lib/app/router.dart`；演示数据开关看 `lib/app/network/network_providers.dart` 的 `useDemoProvider`（`--dart-define=PS_USE_DEMO=true`）。
- 本仓库当前没有 `docs/architecture.md`。架构请读根目录 `README.md` 的目录说明，并以 `lib/app/`、`lib/app/network/`、`packages/infras/core/lib/src/` 的实现为准。

## 2. 文档清单

| 文档 | 内容 | 最后核对 |
| --- | --- | --- |
| [`../README.md`](../README.md) | 工程结构（架构入口）、l10n、测试命令，以及本地运行与联调 | 2026-11-07 |
| 架构（无独立文档） | 以根 README 的目录说明 + 本文件 §4 的代码入口为准；当前没有 `docs/architecture.md` | 2026-11-07 |
| [`page-parity.md`](page-parity.md) | 页面完成度：逐页对照 Android 原项目，记录刻意差异 | 2026-11-07 |
| [`api-contract.md`](api-contract.md) | 前端接口契约：通用约定、登录域实测细节、23 个端点逐条接入状态 | 2026-11-07 |
| [`api/API_CONTRACT.md`](api/API_CONTRACT.md) | 前端副本：顶部指向后端契约，仅保留前端差异与接入状态 | 2026-11-07 |
| [`unimplemented-modules.md`](unimplemented-modules.md) | 未实现模块清单、原因与推进顺序 | 2026-11-07 |
| [`ddd-order-domain.md`](ddd-order-domain.md) | 订单领域模型（DDD 战术模式）的设计说明 | 2026-11-07（本轮仅登记，未逐条复核） |

## 3. 按问题导航

| 我想知道 | 去看 |
| --- | --- |
| 这个页面做到哪一步了、和 Android 差在哪 | [`page-parity.md`](page-parity.md) |
| 某个接口怎么调、失败怎么返回、金额单位 | [`api-contract.md`](api-contract.md) |
| 后端路由/字段的完整定义 | `planstar_kratos_server/docs/api/API_CONTRACT.md` |
| 前端当前真正发哪些请求 | [`api-contract.md`](api-contract.md) §5 |
| 还有哪些页面/能力没做 | [`unimplemented-modules.md`](unimplemented-modules.md) |
| 订单聚合、金额、状态机怎么设计 | [`ddd-order-domain.md`](ddd-order-domain.md) |
| 本地怎么起、怎么连后端 | [`../README.md`](../README.md) 的「本地运行与联调」 |

## 4. 关键代码入口

网络层（跨 feature 共用，不要在业务层自建 Dio）：

- `packages/infras/core/lib/src/network/api_client.dart`：基于 Dio，**永不抛异常**，统一返回 `Result<T>`。
- `lib/app/network/api_config.dart`：环境、base URL、UA、超时；支持 `PS_API_ENV` / `PS_API_BASE` / `PS_HTTP_LOG` 编译期覆盖。
- `lib/app/network/ps_network_interceptor.dart`：UA、`dvid`、`Cookie: psSession`、401 钩子。
- `lib/app/network/ps_request_context.dart`：会话与设备标识的运行时上下文。
- `lib/app/network/network_providers.dart`：Dio / `ApiClient` 的 Riverpod 装配。

业务接口：

- `lib/features/auth/data/planstar_auth_api.dart`：登录、发验证码、图形验证码，当前唯一已接真实后端的域。
- `lib/features/{catalog,discover,message,order,user}/data/planstar_*_api.dart`：已按后端形状写好，但 UI 仍以演示数据为主。

## 5. 维护约定

- 每份文档头部必须保留「适用版本 / 最后核对 / 维护人」元信息；改动文档时同步更新日期。
- 修改页面行为、路由、演示开关或接口路径时，同步更新本索引指向的对应文档；不要新增平行文档。
- 新增文档必须登记到 §2，并说明它解决什么问题、以什么为事实源。
- **改 l10n 文案必须重新生成**：ARB 源在 `lib/l10n/arb/`（feature 级在 `arb/features/<name>/`），生成物在 `lib/l10n/generated/`（入库、勿手改）。改完 ARB 跑 `dart tool/gen_l10n.dart` 并提交产物；CI 会执行 `dart tool/gen_l10n.dart --check`，产物与 ARB 不同步会直接失败。
