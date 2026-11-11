# planstar

> 适用版本：planstar Flutter 1.0.1 · 最后核对：2026-11-11 · 维护：客户端组

「企划星」是一款以「做项目前由网友投票」为核心机制的投票决策类应用：应用内的决策项目
被称为**企划**，涵盖游戏创作、自媒体、小说创作、周边同人等多个分类。「企划」页会显示
多条实时更新的企划审批，用户可化身**星推官**，选择**通过 / 驳回**并写下审批理由。

用户把创作理念、创作内容、创作目标发布为企划时，其实也在厘清自己的创作思路。企划星
就像是一个让人「保持行动、即时反馈」的通道——在发起企划、接受支持的过程中，创作的
动力往往能更加持久。同时，企划星也给不同的人提供了一个交换创意的平台：陌生人常常能
补上一个用户从没想过的角度，还有热心用户会为企划找出「问题」。

产品口径是**企划支持平台**，投票决策与支持交付是同一闭环的前后两段：**立项前**由星推官
投票表达态度与理由（不扣星币）；**立项后**创作者设置回报档位，用户用资金支持企划落地，
并获得周边、内容或参与权益。定位、品类边界与术语对照的唯一事实源是后端仓库的
`planstar_kratos_server/docs/product/POSITIONING.md`。

本仓库是企划星 Flutter 客户端重构工程（monorepo + Clean DDD + Riverpod + GoRouter）。

## 目录

```
packages/infras/core/               平台无关内核（纯 Dart，零 Flutter，可 dart test）
  lib/core.dart              总 barrel
  lib/result.dart            sealed Result / Failure
  lib/domain.dart            Entity / AggregateRoot / ValueObject / Money
  lib/network.dart           信封 + ApiClient（永不抛）+ Dio 工厂 + 重试拦截器
  lib/cache.dart             HTTP 缓存：5 策略 + 带 scope 的缓存键
  lib/upload.dart            分片上传（PartUrlProvider）+ OSS 表单直传
  lib/storage.dart           存储端口 + 无单例 AppStore（适配器在 app 组合根）
  lib/config.dart            配置（幂等异步加载）
  lib/logger.dart            日志（级别由装配方注入）
packages/infras/core_design_system/ 三层设计令牌（L0 色板 → L1 语义槽 → L2 ThemeData，Flutter）
lib/
  app/                  main / app / router / theme / session / 深链表
  shell/                StatefulShellRoute 外壳（底栏）
  features/<name>/      按 feature 切分；文案在 lib/l10n/arb/features/<name>/
  l10n/                 应用级 ARB（只放跨 feature 共用文案）
tool/gen_l10n.dart      l10n 统一生成入口
```

> `packages/infras/` 下只有自建的 `core`（纯 Dart 内核）与 `core_design_system`
> （设计令牌），两者都是 pub workspace 成员。页面完成度与接口接入状态见工程内 `docs/`。

## 本地运行与联调

### 1. 拉依赖

```bash
flutter pub get
```

`packages/infras/core` 与 `packages/infras/core_design_system` 是 pub workspace 成员，
随根工程一起解析，不需要单独 `pub get`。

### 2. 直接运行（不连后端）

```bash
flutter run
```

默认 base 是 `https://api.planstar.top/`（后端 Traefik 实际暴露的生产地址）。
需要指向其他环境时用 `--dart-define=PS_API_BASE=https://<host>/` 覆盖；不覆盖时
真实请求会直接打生产接口，加 `--dart-define=PS_USE_DEMO=true` 可离线跑演示数据。

### 3. 连本地后端

后端（`planstar_kratos_server`）需先在本机 `8098` 端口启动，具体启动方式见
该仓库的 README。

**Android 模拟器**（模拟器内 `10.0.2.2` 指向宿主机）：

```bash
flutter run --dart-define=PS_API_BASE=http://10.0.2.2:8098/
```

**真机**（手机与电脑在同一局域网，替换成电脑的局域网 IP）：

```bash
flutter run --dart-define=PS_API_BASE=http://192.168.1.10:8098/
```

若真机连不上，检查电脑防火墙是否放行 `8098`（业务端口）；后端健康检查在运维端口
`9108`，可用 `http://<局域网 IP>:9108/healthz` 确认后端是否存活。

本机同进程访问（如桌面调试）可直接用：

```bash
flutter run --dart-define=PS_API_BASE=http://127.0.0.1:8098/
```

其他可选参数：

| 参数 | 作用 |
| --- | --- |
| `PS_API_ENV=prod` / `beta` | 选择默认环境（`PS_API_BASE` 优先级更高） |
| `PS_USE_DEMO=true` | 不连后端，全部页面读本地演示数据（测试同样强制此模式） |
| `PS_HTTP_LOG=true` | 打印请求/响应体，默认关闭（避免会话、手机号进日志） |

> `PS_API_BASE` **必须以 `/` 结尾**。Android manifest 已允许明文 HTTP，
> 本地联调不需要额外改网络配置。
>
> 图形验证码 `GET v1/user/captcha` 下发的 `psCaptcha` Cookie 由
> `PsNetworkInterceptor` 自动捕获并回填到后续登录 / 发码请求（一次性，内存态、
> 不落盘），业务层不需要手动处理。

### 4. 当前接入范围

后端注册 **56 条路由 / 55 个唯一端点**（`GET /v1/user/` 是 `GET /v1/user` 的尾斜杠
别名）。客户端 `ApiPaths.all` 共 **42 条**，由 `test/api_paths_test.dart` 锁定；
其中 **38 条**在后端有对应注册，未注册的 4 条是遗留票务路径
（`v1/proxyBuyOrder/myOrders`、`v1/pinTuanOrder/myOrders`、`v1/pinTuanOrder/make`、
`v1/pinTuanCampaign/{id}`），真实模式返回 404，演示模式不受影响。
已接通的范围：登录、企划库（分页/城市过滤/详情/Banner/榜单）、
动态（热门/关注/详情/评论）、消息与会话、订单（列表/详情/报价/下单/退款）、
支付单与轮询、用户资料与收货地址、星币钱包与商城、企划创意叠卡流。
默认真实接口；要离线跑页面或测试时加
`--dart-define=PS_USE_DEMO=true`。逐条对照见 `docs/api-contract.md` §5。

### 企划（创意）Tab —— 核心机制

底栏「企划」对应 `lib/features/project_idea/`，是企划星**做项目前由网友投票**的核心入口。
用户在这里以**星推官**身份审批企划（界面按钮沿用「支持 / 不支持」文案）：

- `/project-idea`：实时企划审批叠卡流——右滑 / 「支持」= **通过**、左滑 / 「不支持」=
  **驳回**、上滑跳过；每次决策可写下审批理由。首次进入与翻卡会拉取
  `GET v1/projectIdeas/feed`（游标分页，剩余 ≤3 张预取）。
- `/project-idea/:ideaId`：企划详情，含支持率、意愿档位分布与理由计数聚合。

这里是**立项前**的态度征集：通过/驳回仅表达态度与理由、不扣星币，详情页会明确标注
「尚未立项」；企划立项后才进入资金支持与回报交付阶段。本地联调按上节指定 `PS_API_BASE`
后即可直接调用 `v1/projectIdeas/*` 三个接口。

## 本地化（一 feature 一套 ARB）

应用级 `lib/l10n/arb/app_zh.arb` **只放跨 feature 共用**的文案：应用名、底栏 Tab、
通用动作（重试/取消/确定）、通用状态（加载/空/网络错误/超时/登录失效）。

各 feature 的文案放 `lib/l10n/arb/features/<name>/<name>_zh.arb`（zh 为模板，
同目录另有 `<name>_en.arb`），生成 `<Name>Localizations`，产物统一落在
`lib/l10n/generated/`。页面里**不直接**用 `XxxLocalizations.of(context)`，而是走
`lib/l10n/l10n.dart` 导出的扁平门面：`context.l10n.key`（key 全局唯一，由
`tool/gen_l10n.dart` 校验）。

### 为什么需要 `tool/gen_l10n.dart`

`flutter gen-l10n` 只读**当前工作目录**的 `l10n.yaml`，并且一旦发现它存在就会
**忽略全部命令行参数**。所以一个 Flutter 工程无法用常规方式维护多套 l10n 配置。

本工程的做法：脚本临时把根 `l10n.yaml` 挪开，逐套用命令行参数生成，再还原。
这样不用把 feature 拆成独立 pub package 就能做到 feature 级 ARB。

```bash
dart tool/gen_l10n.dart
```

脚本会在两种情况下以 exit code 1 失败：
- 某套 ARB 生成失败；
- 某套 ARB 有未翻译的 key（某个语种缺条目）。

### 注意事项

- **生成产物需要入库**。`flutter build` / `flutter run` 只会自动重新生成
  **应用级** l10n，不会管 feature 级；新克隆的仓库若没有生成产物会编译不过。
- **新增 feature 时改两处**：`tool/gen_l10n.dart` 的 `targets` 加一行，
  以及 `lib/app/app.dart` 的 `localizationsDelegates` 加一个 delegate。
  只做前者会在运行期崩（取不到 delegate），只做后者会编译不过。
- 各套 ARB 的语种集合必须一致，由 `test/l10n_wiring_test.dart` 守住。

## 测试

`flutter test` 在本机会因 `HTTP_PROXY` 代理掉 flutter_tester 的本地 WebSocket
而失败（报 `Invalid WebSocket upgrade request`）。绕开：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy flutter test
```

平台无关的 `packages/infras/core` 可以直接 `dart test`（更快）。

## 许可证

本项目采用 **PolyForm Noncommercial License 1.0.0**（SPDX：`PolyForm-Noncommercial-1.0.0`），
完整条款见 [LICENSE](LICENSE)。核心约定：

- **允许**：任何非商业目的，包括个人学习、研究、实验、爱好项目，以及教育机构、
  慈善组织、公共研究机构、政府机构等非商业主体的使用与修改
- **禁止**：任何商业用途；商业使用需另行取得版权所有者授权（版权所有者 uifj 本人不受限制）
- **义务**：分发时须附带本许可证或其链接，并保留 `Required Notice` 版权声明

如需商业授权，请通过 GitHub（@uifj）联系。

Copyright (C) 2026 uifj

