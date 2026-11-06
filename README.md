# planstar

企划星 Flutter 重构工程。monorepo（pub workspace）+ Clean DDD + Riverpod + GoRouter。

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
packages/infras/core_design_system/ 三层设计令牌（TUIKit 风格：L0 色板 → L1 语义槽 → L2 ThemeData，Flutter）
lib/
  app/                  main / app / router / theme / session / 深链表
  shell/                StatefulShellRoute 外壳（底栏）
  features/<name>/      按 feature 切分；每个 feature 自带 l10n/
  l10n/                 应用级 ARB（只放跨 feature 共用文案）
tool/gen_l10n.dart      l10n 统一生成入口
```

> `packages/` 下还有 `pudding` / `appunits` 与 `infras/sentry`，是 vendored 的
> 腾讯 CloudSpace / Stow / TRTC 示例代码，**不在 workspace 里**、不参与解析，
> 也没有企划星业务代码。Android 反编译资料与迁移评估见工程内 `docs/`。

## 本地化（一 feature 一套 ARB）

应用级 `lib/l10n/app_zh.arb` **只放跨 feature 共用**的文案：应用名、底栏 Tab、
通用动作（重试/取消/确定）、通用状态（加载/空/网络错误/超时/登录失效）。

各 feature 的文案放 `lib/features/<name>/l10n/<name>_zh.arb`，
生成 `<Name>Localizations`，页面里用 `XxxLocalizations.of(context).key` 取。

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
