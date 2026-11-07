import 'package:url_launcher/url_launcher.dart';

/// 打开哔哩哔哩的结果。
///
/// 不把异常抛给 UI：拉起外部应用在不同平台上失败方式不一致
/// （`PlatformException` / 返回 false），统一收敛成这个枚举。
enum BilibiliOpenResult {
  /// 已通过 `bilibili://` 拉起客户端。
  openedInApp,

  /// 客户端没拉起来（多半是未安装），已降级用浏览器打开。
  openedInBrowser,

  /// 客户端和浏览器都没打开。
  failed,
}

/// 可注入的 URL 拉起函数（测试用）。
typedef LaunchUrlFn = Future<bool> Function(Uri url, {LaunchMode mode});

/// 从裸号、视频 URL 或带查询参数的链接里提取 bvid。
///
/// 只做字符串识别，不解析短链（`b23.tv/xxxx` 需要网络跳转才能拿到 bvid，
/// 这里返回 null，由调用方决定是否降级）。
String? extractBvid(String? raw) {
  if (raw == null) return null;
  final String text = raw.trim();
  if (text.isEmpty) return null;
  final RegExpMatch? match = RegExp(
    r'[Bb][Vv]([0-9A-Za-z]{10})',
  ).firstMatch(text);
  if (match == null) return null;
  return 'BV${match.group(1)}';
}

/// 打开哔哩哔哩客户端播放指定视频。
///
/// 先尝试 `bilibili://video/<bvid>`；客户端未安装时回退到网页版，
/// 通过返回值告诉调用方走了降级，UI 可据此提示或改走应用内播放。
Future<BilibiliOpenResult> openInApp(
  String bvid, {
  LaunchUrlFn? launchUrlFn,
}) async {
  final String? normalized = extractBvid(bvid);
  if (normalized == null) return BilibiliOpenResult.failed;

  final LaunchUrlFn launch = launchUrlFn ?? _launch;
  try {
    final bool opened = await launch(
      Uri.parse('bilibili://video/$normalized'),
      mode: LaunchMode.externalApplication,
    );
    if (opened) return BilibiliOpenResult.openedInApp;
  } catch (_) {
    // 未安装客户端时 iOS/Android 都会抛或返回 false，统一走降级。
  }

  try {
    final bool opened = await launch(
      Uri.parse('https://www.bilibili.com/video/$normalized'),
      mode: LaunchMode.externalApplication,
    );
    return opened
        ? BilibiliOpenResult.openedInBrowser
        : BilibiliOpenResult.failed;
  } catch (_) {
    return BilibiliOpenResult.failed;
  }
}

Future<bool> _launch(Uri url, {LaunchMode mode = LaunchMode.platformDefault}) {
  return launchUrl(url, mode: mode);
}
