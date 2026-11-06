import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'application/auth_controller.dart';
import 'application/auth_providers.dart';
import 'application/auth_state.dart';
import 'domain/auth_failure.dart';
import '../../l10n/l10n.dart';

/// 登录 / 注册页（`layout_login_register.xml`）。
///
/// ## 结构（尺寸全部对齐来源 XML）
///
/// - 顶部纵向渐变头 `#FFFFE9EF → #FFFFFFFF`：24dp 关闭按钮（距顶 45dp、
///   距左 20dp）→ 24dp 高字标（`ps_logo_name`，marginTop 24dp）→
///   24sp 粗体标题（marginTop 12dp）；
/// - 手机号输入行 52dp（左右 20dp，hint `请输入手机号`）+ 1dp 分隔线；
/// - 验证码行 52dp：左侧输入框 + 右侧 79×30 的「获取验证码」
///   （14sp `#ffff2261`，不可用时 alpha 0.5）；切到密码登录时换成密码行；
/// - 1dp 分隔线 + 48dp 登录按钮（渐变 `#ffff2661 → #ffff5180`，圆角 8，
///   16sp 粗体白字，不可用时 alpha 0.3）；
/// - 36dp 协议行：14dp 勾选框 + 「已阅读并同意《注册协议》和《隐私协议》」
///   （12sp，说明文字 `text_3`、协议名 `text_0`）+ 右对齐的
///   「密码登录 / 验证码登录」；
/// - 底部块（距屏底 64dp）：「更多登录方式」两侧细线 + 46dp 微信入口 +
///   12sp `text_3` 文案。
///
/// ## 这一页现在接的是**真实接口**
///
/// 所有动作都走 [AuthController] → `RemoteAuthRepository` → `v1/user/login` /
/// `v3/user/sendLoginCode` / `v1/user/captcha`（契约由 curl 实测，见
/// `docs/api-contract.md`）。页面自己**不发请求、不拼 token**，只做三件事：
/// 表单校验、把失败翻译成 UI 动作、成功后导航。
///
/// 与来源 `BaseLoginActivity` 的行为对齐点：
///
/// | 场景 | 来源 | 这里 |
/// |---|---|---|
/// | 发码成功 | `showToast("验证码已发送")` + 60s 倒计时 | 同（倒计时在 Controller 里，离开页面不泄漏） |
/// | 验证码错 | toast 服务端原文 `验证码不正确` | 同（`AuthFailureKind.business` 直接展示原文） |
/// | 账号被锁 | 不可取消的 `AlertDialog` | 同（`AuthFailureKind.accountLocked`） |
/// | 风控要图形码 | `lay_captcha` 从 `gone` 切 `visible` 后重试 | 弹 [_CaptchaDialog]，拿字符后**重放原请求** |
/// | 登录成功 | `finish()` + `EventBus` 通知上一页 | 写会话状态 → 路由 redirect 放行 → 回 `from` |
///
/// **密码登录**：来源有这个入口，服务端**当前已关闭**——实测返回
/// `请使用手机号验证码登录，若手机号登录异常，请联系客服`（HTTP 500 +
/// `text/plain`）。所以这里保留切换按钮（UI 对齐），但把服务端原文如实弹出，
/// 不自造"密码错误"之类的假文案。
///
/// ## 与来源的差异（刻意）
///
/// 1. 图形验证码在来源里默认 `gone`，这里是**按需弹出**——`needCaptcha`
///    只在风控触发时出现，做成常驻一行会让 99% 的用户看到一块空白；
/// 2. `btn_back` 也是 `gone`，只保留关闭；关闭时若来源页是登录门禁页
///    （`/order`），未登录会被 redirect 再次踢回登录页，所以退回首页；
/// 3. 微信登录未集成 SDK，点击给出提示而不是拉起授权；
/// 4. 协议页在演示版本里不存在，点击弹说明对话框；
/// 5. 微信图标改用 Lucide 矢量图标重绘（本地图片资源已移除），尺寸仍是 46dp。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.from});

  /// 来源 location（路由 redirect 拼进 `/login?from=`，**已解码**）。
  final String? from;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();

  /// 协议文案里的两处可点片段。`TextSpan.recognizer` 需要自己释放。
  late final TapGestureRecognizer _registerTap = TapGestureRecognizer()
    ..onTap = () => _showTerms(context.l10n.authAgreementRegister);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _showTerms(context.l10n.authAgreementPrivacy);

  bool _passwordMode = false;
  bool _agreed = false;

  static final RegExp _phonePattern = RegExp(r'^1[3-9]\d{9}$');

  /// 图形验证码最多补几轮。服务端如果一直回 `needCaptcha`（或每次都说
  /// 字符错），无限重试会把用户困在对话框里。
  static const int _maxCaptchaRounds = 3;

  @override
  void initState() {
    super.initState();
    // 三个输入框都要触发整页重建：按钮的"看起来能不能点"（alpha 0.3）
    // 和"点了会怎样"都依赖 `_phoneValid` / `_credentialValid`，而这两个
    // 是**在 build 里**读 controller 的。只听 `TextEditingController`
    // 自己的 `ValueListenableBuilder` 只能刷到输入行内部，按钮会一直停在
    // 上一次 build 的可用态（输入了合法手机号，按钮还是灰的）。
    _phone.addListener(_handleInputChanged);
    _code.addListener(_handleInputChanged);
    _password.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _phone.removeListener(_handleInputChanged);
    _code.removeListener(_handleInputChanged);
    _password.removeListener(_handleInputChanged);
    _registerTap.dispose();
    _privacyTap.dispose();
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _phoneValid => _phonePattern.hasMatch(_phone.text.trim());

  bool get _credentialValid =>
      _passwordMode ? _password.text.length >= 6 : _code.text.length == 6;

  bool get _canSubmit => _phoneValid && _credentialValid && _agreed;

  /// 登录成功 / 关闭后要去的地方。
  ///
  /// `from` 已经由 GoRouter 解码过（`Uri.queryParameters` 返回的就是解码值），
  /// 这里**不能再 `decodeComponent`**：来源 location 里如果带 `%20` 之类的
  /// 二次编码，多解一次会把参数解坏（`from=/show/1?kw=a%20b` → `a b`）。
  String get _backLocation {
    final String? raw = widget.from;
    return (raw == null || raw.isEmpty) ? '/' : raw;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// 关闭登录页。门禁页在未登录状态下会把我们弹回来，所以退首页。
  void _close() {
    final String back = _backLocation;
    context.go(back.startsWith('/order') ? '/' : back);
  }

  /// 发登录验证码。
  Future<void> _sendCode() async {
    final l10n = context.l10n;
    if (!_phoneValid) {
      _toast(l10n.authPhoneInvalid);
      return;
    }
    // 冷却中 / 请求在飞：按钮看起来是灰的，这里也必须拦住——
    // 按钮**故意**没有做成 `onTap: null`（见 [_SendCodeButton]），
    // 否则"手机号没填"时点一下就没有任何反馈。
    final AuthState before = ref.read(authControllerProvider);
    if (before.busy || before.inCooldown) {
      return;
    }

    final String phone = _phone.text.trim();
    final AuthController controller = ref.read(authControllerProvider.notifier);

    AuthFailure? failure = await controller.sendCode(phone);
    failure = await _resolveCaptcha(
      failure,
      (String captcha) => controller.sendCode(phone, captcha: captcha),
    );

    if (!mounted) {
      return;
    }
    if (failure == null) {
      _toast(l10n.authCodeSent);
    } else {
      _report(failure);
    }
  }

  /// 提交登录。
  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_phoneValid) {
      _toast(l10n.authPhoneInvalid);
      return;
    }
    if (!_credentialValid) {
      _toast(_passwordMode ? l10n.authPasswordTooShort : l10n.authCodeTooShort);
      return;
    }
    if (!_agreed) {
      _toast(l10n.authAgreementRequired);
      return;
    }
    if (ref.read(authControllerProvider).busy) {
      return;
    }

    final String phone = _phone.text.trim();
    final AuthController controller = ref.read(authControllerProvider.notifier);

    AuthFailure? failure = _passwordMode
        ? await controller.loginWithPassword(phone, _password.text)
        : await controller.loginWithCode(phone, _code.text);
    failure = await _resolveCaptcha(
      failure,
      (String captcha) => _passwordMode
          ? controller.loginWithPassword(
              phone,
              _password.text,
              captcha: captcha,
            )
          : controller.loginWithCode(phone, _code.text, captcha: captcha),
    );

    if (!mounted) {
      return;
    }
    if (failure == null) {
      // 会话已经写进 AuthController，路由的 refreshListenable 会重跑
      // redirect 把 `/login` 换成 `from`；这里显式 go 一次是为了带上
      // `from` 里的 query（redirect 的 rule 3 只认 `from`，够用但不覆盖
      // "登录页是被 push 出来的" 这种情况）。
      context.go(_backLocation);
      return;
    }
    _report(failure);
  }

  /// 把 `needsCaptcha` 补成一次带图形码的重放。
  ///
  /// [retry] 是"用这个图形码把原请求再发一次"——发码和登录的请求体不同
  /// （`code` vs `pw`），所以由调用方注入，而不是在这里按模式猜。
  ///
  /// 返回 `null` 有两种含义，调用方都当作"没失败"处理：
  /// - 请求本来就成功；
  /// - 用户在图形码对话框上点了取消（此时不该再弹一次错误）。
  ///
  /// 后者其实是"静默放弃"，但两者在 UI 上的正确反应完全一样（不报错），
  /// 所以不额外引入一个三态返回值。
  Future<AuthFailure?> _resolveCaptcha(
    AuthFailure? failure,
    Future<AuthFailure?> Function(String captcha) retry,
  ) async {
    var rounds = 0;
    while (failure != null &&
        failure.needsCaptcha &&
        rounds < _maxCaptchaRounds) {
      rounds++;
      final String? captcha = await _askCaptcha(failure.message);
      if (captcha == null) {
        return null;
      }
      failure = await retry(captcha);
    }
    return failure;
  }

  /// 把失败翻译成 UI 动作（弹框 / toast）。
  void _report(AuthFailure failure) {
    final l10n = context.l10n;
    switch (failure.kind) {
      case AuthFailureKind.accountLocked:
        unawaited(_showAccountLocked(failure.message));
      case AuthFailureKind.network:
        _toast(l10n.authNetworkError);
      case AuthFailureKind.timeout:
        _toast(l10n.authTimeoutError);
      case AuthFailureKind.business:
      case AuthFailureKind.needsCaptcha:
      case AuthFailureKind.unauthorized:
      case AuthFailureKind.unknown:
        // 服务端原文优先：企划星的错误体是 `text/plain` 中文，翻译只会更差。
        _toast(
          failure.message.isEmpty ? l10n.authUnknownError : failure.message,
        );
    }
  }

  /// 账号锁定：来源是**不可取消**的对话框，只有"我知道了"能关。
  Future<void> _showAccountLocked(String message) {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.authAccountLockedTitle),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.authTermsConfirm),
          ),
        ],
      ),
    );
  }

  /// 弹图形验证码，返回用户输入的字符（取消返回 `null`）。
  Future<String?> _askCaptcha(String? serverMessage) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          _CaptchaDialog(serverMessage: serverMessage),
    );
  }

  void _showTerms(String title) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(l10n.authTermsBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.authTermsConfirm),
          ),
        ],
      ),
    );
  }

  /// 用户改了输入：清掉上一次失败（否则"验证码不正确"会一直挂在状态里），
  /// 并重建页面让按钮的可用态跟着变。
  void _handleInputChanged() {
    if (!mounted) {
      return;
    }
    ref.read(authControllerProvider.notifier).clearFailure();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AppColors colors = context.appColors;
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    final AuthState auth = ref.watch(authControllerProvider);

    final bool busy = auth.busy;
    final int countdown = auth.cooldownSeconds;

    return AdaptiveScaffold(
      backgroundColor: colors.bgCard,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Header(
                    topInset: safe.top,
                    title: l10n.authLoginTitle,
                    onClose: _close,
                  ),
                  // 手机号：来源 marginTop 10dp，左右 20dp。
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 20,
                    ),
                    child: _LoginField(
                      controller: _phone,
                      hint: l10n.authPhoneHint,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                  ),
                  const _LoginDivider(),
                  if (_passwordMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _LoginField(
                        controller: _password,
                        hint: l10n.authPasswordHint,
                        obscureText: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(20),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _LoginField(
                                controller: _code,
                                hint: l10n.authCodeHint,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            _SendCodeButton(
                              label: auth.sendingCode
                                  ? l10n.authSendingCode
                                  : countdown > 0
                                  ? l10n.authResendCode(countdown)
                                  : l10n.authSendCode,
                              enabled: countdown == 0 && _phoneValid && !busy,
                              onTap: _sendCode,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const _LoginDivider(),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: _LoginButton(
                      label: auth.loggingIn
                          ? l10n.authLoggingIn
                          : l10n.authTitle,
                      enabled: _canSubmit && !busy,
                      onTap: _submit,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SizedBox(
                      height: 36,
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 20),
                          _AgreementCheckbox(
                            // 测试钩子：14dp 的圆形勾选框没有文案可定位。
                            key: const ValueKey<String>('login.agreement'),
                            checked: _agreed,
                            onTap: () => setState(() => _agreed = !_agreed),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _agreed = !_agreed),
                              child: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(text: l10n.authAgreementPrefix),
                                    TextSpan(
                                      text: l10n.authAgreementRegister,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                      ),
                                      recognizer: _registerTap,
                                    ),
                                    TextSpan(text: l10n.authAgreementAnd),
                                    TextSpan(
                                      text: l10n.authAgreementPrivacy,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                      ),
                                      recognizer: _privacyTap,
                                    ),
                                  ],
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                setState(() => _passwordMode = !_passwordMode),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Text(
                                _passwordMode
                                    ? l10n.authSwitchToCode
                                    : l10n.authSwitchToPassword,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomWays(
            bottomInset: safe.bottom,
            label: l10n.authMoreWays,
            wechatLabel: l10n.authWechatLogin,
            onWechat: () => _toast(l10n.authWechatUnavailable),
          ),
        ],
      ),
    );
  }
}

/// 图形验证码对话框。
///
/// 来源的 `lay_captcha` 是**内联**在验证码行下面的一行（`ImageView` +
/// `EditText` + 刷新按钮），从 `gone` 切 `visible`。这里改成对话框：
/// 风控是低频事件，为它长期占一行 40dp 不划算；对话框还能保证"必须处理
/// 完才能继续"，与来源"不填图形码就发不出去"的效果一致。
///
/// 图片是 `v1/user/captcha` 直接返回的 PNG 字节（`image/png`），
/// 不是 base64、不是 URL，所以用 [Image.memory]。
class _CaptchaDialog extends ConsumerStatefulWidget {
  const _CaptchaDialog({this.serverMessage});

  /// 服务端给的原因（`图形验证码错误` / `需要图形验证码`），可能为空。
  final String? serverMessage;

  @override
  ConsumerState<_CaptchaDialog> createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends ConsumerState<_CaptchaDialog> {
  final TextEditingController _input = TextEditingController();

  Uint8List? _image;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .fetchCaptcha();
    if (!mounted) {
      return;
    }
    final l10n = context.l10n;
    result.fold(
      onFailure: (_) => setState(() {
        _loading = false;
        _image = null;
        _error = l10n.authCaptchaLoadFailed;
      }),
      onSuccess: (List<int> bytes) => setState(() {
        _loading = false;
        // 空字节也当失败：`Image.memory([])` 会抛，别让对话框炸掉。
        _image = bytes.isEmpty ? null : Uint8List.fromList(bytes);
        _error = _image == null ? l10n.authCaptchaLoadFailed : null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AppColors colors = context.appColors;

    return AlertDialog(
      title: Text(l10n.authCaptchaTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (widget.serverMessage != null && widget.serverMessage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.serverMessage!,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _loading ? null : () => unawaited(_load()),
            child: SizedBox(
              height: 44,
              child: Center(child: _buildImage(colors)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _input,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(8),
            ],
            onSubmitted: (String value) =>
                Navigator.of(context).pop(value.trim()),
            decoration: InputDecoration(
              isDense: true,
              hintText: l10n.authCaptchaHint,
              border: const OutlineInputBorder(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _loading ? null : () => unawaited(_load()),
              child: Text(l10n.authCaptchaRefresh),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.authCaptchaCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_input.text.trim()),
          child: Text(l10n.authCaptchaConfirm),
        ),
      ],
    );
  }

  Widget _buildImage(AppColors colors) {
    if (_loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final Uint8List? image = _image;
    if (image == null) {
      return Text(
        _error ?? '',
        style: TextStyle(fontSize: 12, color: colors.textTertiary),
      );
    }
    return Image.memory(
      image,
      height: 40,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Text(
        _error ?? '',
        style: TextStyle(fontSize: 12, color: colors.textTertiary),
      ),
    );
  }
}

/// 顶部渐变头：关闭按钮 + 字标 + 标题。
class _Header extends StatelessWidget {
  const _Header({
    required this.topInset,
    required this.title,
    required this.onClose,
  });

  final double topInset;
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        // 品牌淡色 → 卡片底，替代原 `gradient_ffe9ef_to_ffffff` 洋红渐层。
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[colors.brandSubtle, colors.bgCard],
        ),
      ),
      // 来源：btn_close marginTop 45dp、marginStart 20dp。45dp 是距屏幕顶的
      // 绝对距离，含状态栏，所以这里减掉安全区再补回去。
      padding: EdgeInsets.only(top: topInset + 21, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Icon(LucideIcons.x, size: 24, color: colors.textPrimary),
          ),
          const SizedBox(height: 24),
          // 品牌字标：本地图片资源已移除，改用 Lucide 星标 + 文字。
          SizedBox(
            height: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(LucideIcons.sparkles, size: 20, color: colors.brand),
                const SizedBox(width: 6),
                Text(
                  context.l10n.appTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.brand,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 52dp 输入行（对应 `EditTextHasClear`：有内容时右侧出现清除按钮）。
class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.appColors;
    return SizedBox(
      height: 52,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              inputFormatters: inputFormatters,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: colors.brand,
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: TextStyle(fontSize: 15, color: colors.textDisabled),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue value, Widget? _) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.clear,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    LucideIcons.circleX,
                    size: 16,
                    color: colors.textDisabled,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 1dp 分隔线（`view_divider_light`，左右 20dp）。
class _LoginDivider extends StatelessWidget {
  const _LoginDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(height: 1, color: context.appColors.divider),
    );
  }
}

/// 79×30 的「获取验证码」，不可用时 alpha 0.5（与来源一致）。
///
/// `⚠` 不可用时**仍然挂 onTap**（只是变淡），由 [_LoginPageState._sendCode]
/// 自己判断"手机号没填 → 提示"还是"冷却中 → 忽略"。挂 `null` 的话，
/// 用户在没填手机号时点一下会毫无反应，看起来像页面卡住了。
class _SendCodeButton extends StatelessWidget {
  const _SendCodeButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 79,
        height: 30,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 14,
              color: colors.price.withValues(alpha: enabled ? 1 : 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// 48dp 渐变登录按钮（`login_button_gradient`，圆角 8）。
///
/// 同 [_SendCodeButton]：不可用时只降透明度，不摘 `onTap`——这样"没勾协议"
/// "验证码位数不对"都能给出具体原因，而不是点了没动静。
class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.3,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // TUIKit 主按钮是纯品牌蓝实底，不用渐变。
            color: context.appColors.brand,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}

/// 14dp 协议勾选框（`ic_uncheck` 未随资源迁移，按品牌色重绘）。
class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({
    super.key,
    required this.checked,
    required this.onTap,
  });

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 14,
        height: 14,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: checked ? colors.brand : null,
            border: checked ? null : Border.all(color: colors.textDisabled),
          ),
          child: checked
              ? const Icon(
                  LucideIcons.check,
                  size: 10,
                  color: Color(0xFFFFFFFF),
                )
              : null,
        ),
      ),
    );
  }
}

/// 底部：更多登录方式 + 微信入口（整块距屏底 64dp）。
class _BottomWays extends StatelessWidget {
  const _BottomWays({
    required this.bottomInset,
    required this.label,
    required this.wechatLabel,
    required this.onWechat,
  });

  final double bottomInset;
  final String label;
  final String wechatLabel;
  final VoidCallback onWechat;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 20, right: 5),
                  color: colors.divider,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 5, right: 20),
                  color: colors.divider,
                ),
              ),
            ],
          ),
          // 来源 marginBottom 30dp。
          const SizedBox(height: 30),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onWechat,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07C160),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.messageCircle,
                    size: 30,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  wechatLabel,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
