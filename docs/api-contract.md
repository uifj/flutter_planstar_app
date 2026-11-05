# 登录接口契约（实测）

> 本文是 `lib/features/auth/` 与 `lib/app/network/` 的**事实依据**。
> 所有结论都来自对原生产 API 的真实请求（2026-11，`curl` +
> `dart run tool/verify_login_api.dart`），不是从反编译代码里推断的。
> 品牌重构后 host / UA 已统一换成 `planstar` 占位值（见
> `lib/app/network/api_config.dart`），下表里的域名不再指向真实线上服务；
> 联调真接口请显式传 `--base` 或设 `PS_API_BASE`。
> 反编译代码只用来回答"客户端**打算**怎么发"，不回答"服务端**现在**怎么收"。

## 1. 环境与请求头

| 项 | 值 | 出处 |
|---|---|---|
| 生产 base | `https://api.planstar.com/` | `HttpUtil.HOST` |
| Beta base | `http://apibeta.planstar.com/`（**明文 HTTP**） | `HttpUtil.HOST_BETA` |
| `User-Agent` | `PlanstarApi (com.planstar.app/9.9.39 <brand> <channel> Android/<os>)` | `HttpUtil.getAPIUserAgent()` |
| `dvid` | 37 字符：36 位 UUID + 第 4 位再追加一次 | 服务端下发 + 本地持久化 |
| `X-Longitude` / `X-Latitude` | 仅当两者都 `> 0` 时加 | `OkHttpUtil` 拦截器 |
| `Cookie` | `psSession=<token>`（登录后） | `OkHttpUtil.addCookie` |
| `Authorization` | **不存在** | — |

`ct`（请求体里的客户端类型）固定 `11` = Android（`PlanstarConstants.CLIENT_TYPE`）。
后端按它决定返回哪些字段，改值会拿到不同的数据形状。

## 2. 端点

### 2.1 提交登录

```http
POST /v1/user/login
Content-Type: application/json

{"ua":"13800138000","code":"123456","ct":11}      // 验证码登录
{"ua":"13800138000","pw":"a1234567","ct":11}      // 密码登录（服务端已关闭，见 §4）
{"ua":"13800138000","code":"123456","captcha":"ab3d","ct":11}  // 风控要图形码时
```

成功：`200` + **裸 `LoginBean`**（不是 `{code,message,data}` 信封）

```json
{"needCaptcha":false,"newUser":true,
 "user":{"userId":90012345,"userName":"票友小张","avatar":"https://…",
         "bio":"…","gender":1,"birthday":946656000000,
         "mobileNo":"13800138000","level":3,"followerNum":12,
         "followingNum":38,"wantWatchNum":7,"isDouliUser":false,
         "badgeIcon":""}}
```

响应头带 **`psSession`**——这就是会话令牌。来源从响应头取：

```java
AccountService.getInstance().setPner(response.headers().get("psSession"));
```

### 2.2 发送登录验证码

```http
POST /v3/user/sendLoginCode
Content-Type: application/json

{"ua":"13800138000"}                     // 首次
{"ua":"13800138000","captcha":"ab3d"}    // 风控要图形码后
```

注意**版本错位**：发码在 `v3`，提交登录在 `v1`。来源就是这样，不要"顺手统一"。

这个接口的成功/失败**都是 `200`**，靠 body 里的 `success` 区分：

```json
{"success":true,"needCaptcha":false}                                   // 短信已下发
{"success":false,"needCaptcha":true,"errorMsg":"请输入图形验证码"}      // 风控要图形码
{"success":false,"needCaptcha":true,"errorMsg":"图形验证码错误"}        // 图形码输错
{"success":false,"needCaptcha":false,"errorMsg":"发送失败"}             // 其他失败
```

### 2.3 图形验证码

```http
GET /v1/user/captcha
```

`200` + `Content-Type: image/png`，body 是 **PNG 原始字节**（不是 base64、
不是 URL、**不带 `Set-Cookie`**）。实测单张 3.0–3.9 KB。

## 3. 失败的两种风格（最容易踩的坑）

同一条登录流程里混着两种错误表达，实现必须两种都支持：

| 接口 | 失败形态 | 用户可见文案从哪来 |
|---|---|---|
| `v1/user/login` | `HTTP 400/500` + `Content-Type: text/plain;charset=UTF-8` | **正文原文** |
| `v3/user/sendLoginCode` | `HTTP 200` + `{"success":false,"errorMsg":"…"}` | `errorMsg` |

实测原文（逐条已固化进 `test/features/auth/remote_auth_repository_test.dart`）：

```
POST /v1/user/login  {"ua":"…","code":"000000","ct":11}
→ 500 text/plain  «验证码不正确»

POST /v1/user/login  {"ua":"…","pw":"a1234567","ct":11}
→ 500 text/plain  «请使用手机号验证码登录，若手机号登录异常，请联系客服»

POST /v1/user/login  {"ua":"…","ct":11}          （两个凭证都不带）
→ 400 text/plain  «请输入密码»
```

`text/plain` 这一条直接决定了 `ApiClient._messageOf` 的实现：只认
`{message}` / `{msg}` 会让上面每一句都退化成
「服务开小差了，请稍后重试」，把唯一有用的信息丢掉。来源是
`showToast(response.errorBody().string())`，即**原文直弹**。

同时要设边界：CDN / 网关的 HTML 错误页（`<!DOCTYPE html>…`）不能弹给用户，
超长正文截断（120 字符）。

## 4. 密码登录已关闭

任何带 `pw` 的请求都返回
`500 请使用手机号验证码登录，若手机号登录异常，请联系客服`。

因此：

- UI 保留"密码登录"入口（对齐来源 `layout_login_register.xml`）；
- **不自造**"密码错误"之类的文案，如实展示服务端原文；
- 端口 `AuthRepository.loginWithPassword` 保留——开关在服务端，客户端不替它决定。

## 5. 图形验证码门（风控）

```
1. POST sendLoginCode {ua}
   → 200 {success:false, needCaptcha:true, errorMsg:"请输入图形验证码"}
2. GET  captcha                        → image/png
3. POST sendLoginCode {ua, captcha:"ab3d"}
   → 200 {success:false, needCaptcha:true, errorMsg:"图形验证码错误"}   ← 输错，可重试
   → 200 {success:true}                                              ← 通过，短信下发
```

关键点：**第 2 步的图和第 3 步的码之间没有 cookie 关联**（`v1/user/captcha`
不返回 `Set-Cookie`），服务端按 `dvid` + IP 关联。所以客户端只要保证
`dvid` 在整个流程中不变即可——这也是 `dvid` 必须持久化的原因之一。

`needCaptcha` 出现在**两个**地方，都要处理：

- 发码响应里的 `needCaptcha`（`SendCodeResponseDto`）；
- 登录响应里的 `needCaptcha`（`LoginResponseDto`）。

## 6. 服务端行为随 IP / 时段漂移

同一台机器上连续观测到过：

```
{"success":false,"needCaptcha":false,"errorMsg":"发送失败"}          ← 早期
{"success":false,"needCaptcha":true,"errorMsg":"请输入图形验证码"}    ← 现在
```

换手机号、加经纬度头、切 beta 都一样。**这是服务端风控，不是请求形状错了。**
所以：

- `tool/verify_login_api.dart` 把"发码"当**观测项**，只对"补了图形码之后
  服务端怎么回"做断言（那一步是确定的）；
- UI 必须能同时处理 `needCaptcha:false + 发送失败`（直接提示）和
  `needCaptcha:true`（弹图形码）两种分支。

## 7. 怎么验证

```bash
# 失败路径（无需验证码，可进 CI）
dart run tool/verify_login_api.dart

# 完整成功路径：在真机 App 上收一次验证码，填进来
dart run tool/verify_login_api.dart --phone=13800001234 --code=123456
```

当前结果（2026-11）：

```
✓ 图形验证码 GET v1/user/captcha              3796 字节，PNG 魔数正确
○ 发送登录验证码 POST v3/user/sendLoginCode    needCaptcha=true errorMsg=请输入图形验证码
✓ 错误图形码 POST v3/user/sendLoginCode        「图形验证码错误」← 补码重放循环有效
✓ 错误验证码 POST v1/user/login                HTTP 500 →「验证码不正确」
✓ 密码登录 POST v1/user/login                  HTTP 500 →「请使用手机号验证码登录…」
✓ 空凭证 POST v1/user/login                    HTTP 400 →「请输入密码」
```

## 8. 来源 → 本项目的落点

| 来源（Java） | 本项目（Dart） |
|---|---|
| `LoginService.login(JSONObject)` | `PlanstarAuthApi.login` |
| `LoginService.sendLoginCode(JSONObject)` | `PlanstarAuthApi.sendLoginCode` |
| `LoginBean` | `LoginResponseDto` + `AuthUser` |
| `BaseLoginActivity` 的 5 份倒计时 `Handler` | `AuthController` 的 1 个 `Timer`（`ref.onDispose` 取消） |
| `AccountService.setPner(header.get("psSession"))` | `PsNetworkInterceptor` 从响应头抓 → `PsRequestContext.psSession` |
| `AccountService.getPner()` 存明文 prefs | `AuthSessionStore` 存 `SecureStore`（Keystore/Keychain） |
| `profile` 存 URL 编码 JSON | 存纯 JSON（避开 `+`→空格） |
| `str.contains("该账号已被锁定")` | `Failure.code = AUTH_ACCOUNT_LOCKED` → `AuthFailureKind.accountLocked` |
| `showToast(errorBody().string())` | `AuthFailure.message`（服务端原文） |

## 9. 已知差异（刻意）

1. **不发明文 `psSession`**：来源存 `SharedPreferences` 明文，这里进安全存储。
2. **不发 `channelAttributeInfo`**：来源密码分支会带一个广告归因 JSON
   （androidId / clickid / oaid）。它只影响投放归因，不影响鉴权；我们没有
   OAID/clickId，发一串 `null` 反而可能被判脏数据。
3. **没有 `/logout` 接口**：来源也不发登出请求（`AccountService.logout()`
   只清本地），服务端 `psSession` 等它自己过期。
4. **图形验证码是对话框而不是内联一行**：来源 `lay_captcha` 默认 `gone`，
   风控时切 `visible`。这里做成按需弹框，避免 99% 的用户看到一块空白。
