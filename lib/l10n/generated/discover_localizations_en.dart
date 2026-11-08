// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'discover_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class DiscoverLocalizationsEn extends DiscoverLocalizations {
  DiscoverLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get discoverTitle => 'Discover';

  @override
  String get feedProviders_18 => 'Me';

  @override
  String get feedProviders_25 => 'Just posted';

  @override
  String get discoverPage_39 => 'Popular';

  @override
  String get discoverPage_39_2 => 'Following';

  @override
  String get discoverPage_72 => 'People you follow haven\'t posted anything new yet';

  @override
  String get discoverPage_73 => 'Head to Popular to see what everyone is talking about';

  @override
  String get discoverPage_75 => 'View popular';

  @override
  String feedPost_65(Object toStringAsFixed) {
    return '${toStringAsFixed}k';
  }

  @override
  String feedPost_73(Object toStringAsFixed) {
    return '${toStringAsFixed}k';
  }

  @override
  String get feedPost_115 => 'Just now';

  @override
  String feedPost_116(Object inMinutes) {
    return '${inMinutes}m ago';
  }

  @override
  String feedPost_117(Object inHours) {
    return '${inHours}h ago';
  }

  @override
  String get feedPost_118 => 'Yesterday';

  @override
  String feedPost_119(Object inDays) {
    return '${inDays}d ago';
  }

  @override
  String feedPost_120(Object month, Object day) {
    return '$month/$day';
  }

  @override
  String get feedDetailPage_45 => 'Post details';

  @override
  String get feedDetailPage_48 => 'Post not found';

  @override
  String get feedDetailPage_49 => 'It may have been deleted by the author';

  @override
  String get feedDetailPage_51 => 'Back to Discover';

  @override
  String get feedDetailPage_125 => 'Related projects';

  @override
  String feedDetailPage_151(Object length) {
    return '$length comments';
  }

  @override
  String get feedDetailPage_161 => 'No comments yet';

  @override
  String get feedDetailPage_162 => 'Say something';

  @override
  String feedDetailPage_216(Object publishedAt, Object viewCountLabel) {
    return '$publishedAt · $viewCountLabel views';
  }

  @override
  String get feedDetailPage_252 => 'This post contains a video, but the player isn\'t integrated yet (needs a CDN and an equivalent videoplayer implementation)';

  @override
  String get feedDetailPage_276 => 'Like API not integrated yet';

  @override
  String get feedDetailPage_281 => 'Comment';

  @override
  String get feedDetailPage_282 => 'Comment posting not integrated yet';

  @override
  String get feedDetailPage_287 => 'Share';

  @override
  String get feedDetailPage_288 => 'Share panel not integrated yet — fluwx';

  @override
  String get publishSheet_69 => 'New post';

  @override
  String get publishSheet_98 => 'Share a project you have supported…';

  @override
  String get publishSheet_122 => 'Post';

  @override
  String get bilibiliOpenSheet_32 => 'Play video';

  @override
  String get bilibiliOpenSheet_41 => 'Play in app';

  @override
  String get bilibiliOpenSheet_46 => 'Open bilibili';

  @override
  String get bilibiliOpenSheet_72 => 'bilibili isn\'t installed. Opened in browser.';

  @override
  String get bilibiliOpenSheet_80 => 'Couldn\'t open the video. Please try again.';

  @override
  String get bilibiliPlayerPage_79 => 'Couldn\'t open the browser. Please try again.';

  @override
  String get bilibiliPlayerPage_89 => 'bilibili';

  @override
  String get bilibiliPlayerPage_93 => 'Refresh';

  @override
  String get bilibiliPlayerPage_98 => 'Open in browser';

  @override
  String get bilibiliPlayerPage_112 => 'Video failed to load';

  @override
  String get bilibiliPlayerPage_113 => 'Check your network and try again';
}
