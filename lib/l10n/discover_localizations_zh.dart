// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'discover_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class DiscoverLocalizationsZh extends DiscoverLocalizations {
  DiscoverLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get discoverTitle => '发现';

  @override
  String get feedProviders_18 => '我';

  @override
  String get feedProviders_25 => '刚刚发布';

  @override
  String get discoverPage_39 => '热门';

  @override
  String get discoverPage_39_2 => '关注';

  @override
  String get discoverPage_72 => '关注的人还没有新动态';

  @override
  String get discoverPage_73 => '去热门看看大家在聊什么';

  @override
  String get discoverPage_75 => '查看热门';

  @override
  String feedPost_65(Object toStringAsFixed) {
    return '$toStringAsFixed万';
  }

  @override
  String feedPost_73(Object toStringAsFixed) {
    return '$toStringAsFixed万';
  }

  @override
  String get feedPost_115 => '刚刚';

  @override
  String feedPost_116(Object inMinutes) {
    return '$inMinutes分钟前';
  }

  @override
  String feedPost_117(Object inHours) {
    return '$inHours小时前';
  }

  @override
  String get feedPost_118 => '昨天';

  @override
  String feedPost_119(Object inDays) {
    return '$inDays天前';
  }

  @override
  String feedPost_120(Object month, Object day) {
    return '$month月$day日';
  }

  @override
  String get feedDetailPage_45 => '动态详情';

  @override
  String get feedDetailPage_48 => '动态不存在';

  @override
  String get feedDetailPage_49 => '它可能已被作者删除';

  @override
  String get feedDetailPage_51 => '返回发现';

  @override
  String get feedDetailPage_125 => '相关演出';

  @override
  String feedDetailPage_151(Object length) {
    return '评论 $length';
  }

  @override
  String get feedDetailPage_161 => '还没有评论';

  @override
  String get feedDetailPage_162 => '来说两句吧';

  @override
  String feedDetailPage_216(Object publishedAt, Object viewCountLabel) {
    return '$publishedAt · $viewCountLabel 阅读';
  }

  @override
  String get feedDetailPage_252 => '这条动态带视频，播放器尚未接入（需要 CDN 与 videoplayer 等价实现）';

  @override
  String get feedDetailPage_276 => '点赞接口待接入';

  @override
  String get feedDetailPage_281 => '评论';

  @override
  String get feedDetailPage_282 => '评论发布待接入';

  @override
  String get feedDetailPage_287 => '分享';

  @override
  String get feedDetailPage_288 => '分享面板待接入 fluwx';

  @override
  String get publishSheet_69 => '发布动态';

  @override
  String get publishSheet_98 => '聊聊你看过的演出…';

  @override
  String get publishSheet_122 => '发布';
}
