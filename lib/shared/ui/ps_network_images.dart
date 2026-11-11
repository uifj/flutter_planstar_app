/// 开源免费图源（Lorem Picsum，图片来自 Unsplash，免费可商用）。
///
/// 本地 `assets/` 已整体移除：所有演示图片统一走网络，且每个调用点都保留
/// `errorBuilder` 兜底。seed 决定图片内容，同一 seed 每次都拿到同一张图。
library;

abstract final class PsImages {
  static const String _base = 'https://picsum.photos/seed';

  /// 默认头像。
  static const String defaultAvatar =
      'https://picsum.photos/seed/planstar-avatar/160/160';

  /// 按 seed 生成确定性的方形头像 URL。
  static String avatar(String seed, {int size = 160}) =>
      '$_base/${_hash(seed)}/$size/$size';

  /// 按 seed 生成确定性的海报 / 配图 URL。
  static String poster(String seed, {int width = 320, int height = 440}) =>
      '$_base/${_hash(seed)}/$width/$height';

  static int _hash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return hash;
  }
}
