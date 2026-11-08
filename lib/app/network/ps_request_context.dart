/// 每个请求都要带的运行时上下文（`dvid` / `psSession` / 经纬度）。
///
/// 为什么是一个**可变对象**而不是不可变配置：拦截器是同步的
/// （`Interceptor.onRequest` 不能 await），而 `dvid` 与 `psSession` 都要从磁盘
/// 读。来源的做法是 `OkHttpUtil.getDvid()` 里同步读 SharedPreferences
/// （内存缓存），等价于"启动时灌一次、之后只改内存"。
///
/// 这里把同一件事显式化：
///
/// - 启动时由 `loadAppBootstrap` 从存储灌初值；
/// - 之后只改这个对象（登录写 `psSession`、服务端下发新 `dvid` 时写 `dvid`），
///   落盘由各自的回调异步补上；
/// - 拦截器只读它，因此不需要 `await`。
///
/// `⚠` 这里刻意**不**持有 Riverpod 的 ref，也不 import `features/auth`：
/// 网络层不能反向依赖业务层，否则 `authRepository → apiClient → dio →
/// authRepository` 成环。登出这种副作用通过 [onUnauthorized] 这个钩子由
/// 业务层在构建时注册进来。
library;

/// 请求上下文。
final class PsRequestContext {
  /// 创建上下文。
  PsRequestContext({this.dvid, this.psSession, this.longitude, this.latitude});

  /// 设备标识。
  ///
  /// `null` 表示还没拿到——此时不发 `dvid` 头，由服务端下发后经
  /// [onDeviceIdChanged] 补上。
  String? dvid;

  /// 会话令牌。
  ///
  /// 企划星的会话不是 `Authorization: Bearer`，而是 **Cookie `psSession`**：
  /// 登录响应头里下发 `psSession`，之后每个请求带 `Cookie: psSession=…`。
  /// 来源把它同时存进 SharedPreferences 与 WebView 的 CookieManager。
  String? psSession;

  /// 图形验证码会话标识（Cookie `psCaptcha`）。
  ///
  /// 服务端 `GET v1/user/captcha` 通过 `Set-Cookie: psCaptcha=<id>` 下发，
  /// `POST v1/user/login` / `POST v3/user/sendLoginCode` 会从请求 Cookie 读取它。
  ///
  /// **一次性、仅内存、不落盘**：这两个接口会消费它，无论成功失败都要清空，
  /// 下次需要时重新拉图形验证码即可。
  String? psCaptcha;

  /// 经度。`null` 表示未定位，此时不发 `X-Longitude`。
  double? longitude;

  /// 纬度。`null` 表示未定位，此时不发 `X-Latitude`。
  double? latitude;

  /// 是否已登录（有 `psSession`）。
  bool get hasSession => (psSession ?? '').isNotEmpty;

  /// 服务端下发了新的 `dvid` 时回调（用于落盘）。
  void Function(String dvid)? onDeviceIdChanged;

  /// 收到 401 时回调（用于全局登出）。
  ///
  /// `⚠` 来源在**网络拦截器里直接** `AccountService.logout()`（05 页 §3.2），
  /// 副作用藏在传输层、且新增一个会返 401 的接口就会莫名把用户踢下线。
  /// 这里保留"401 → 登出"的语义，但把它变成一个显式注册的钩子：
  /// 只有业务层订阅了才生效，测试里不注册就什么都不发生。
  void Function()? onUnauthorized;

  /// 清空会话（登出）。
  void clearSession() => psSession = null;

  /// 清空一次性图形验证码标识（已消费或已失效）。
  void clearCaptcha() => psCaptcha = null;
}
