import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/discover/application/bilibili_launcher.dart';
import 'package:planstar/features/discover/domain/feed_post.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  group('extractBvid', () {
    test('裸 bvid 原样返回', () {
      expect(extractBvid('BV1xx411c7mD'), 'BV1xx411c7mD');
    });

    test('完整 URL 带查询参数也能提取', () {
      expect(
        extractBvid(
          'https://www.bilibili.com/video/BV1GJ411x7h7/'
          '?spm_id_from=333.788&vd_source=abc',
        ),
        'BV1GJ411x7h7',
      );
    });

    test('短链不做网络解析，返回 null', () {
      expect(extractBvid('https://b23.tv/abcd123'), isNull);
    });

    test('空值与无 bvid 文本返回 null', () {
      expect(extractBvid(null), isNull);
      expect(extractBvid('  '), isNull);
      expect(extractBvid('av170001'), isNull);
    });
  });

  group('openInApp 的降级分支', () {
    test('客户端拉起来时返回 openedInApp', () async {
      final List<Uri> calls = <Uri>[];
      final BilibiliOpenResult result = await openInApp(
        'BV1xx411c7mD',
        launchUrlFn: (Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) {
          calls.add(uri);
          return Future<bool>.value(true);
        },
      );

      expect(result, BilibiliOpenResult.openedInApp);
      expect(calls, hasLength(1));
      expect(calls.single.toString(), 'bilibili://video/BV1xx411c7mD');
    });

    test('外部应用失败 → 回退浏览器并返回 openedInBrowser', () async {
      final List<Uri> calls = <Uri>[];
      final BilibiliOpenResult result = await openInApp(
        'BV1xx411c7mD',
        launchUrlFn: (Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) {
          calls.add(uri);
          // 模拟未安装客户端：自定义 scheme 返回 false，https 能打开。
          return Future<bool>.value(uri.scheme == 'https');
        },
      );

      expect(result, BilibiliOpenResult.openedInBrowser);
      expect(calls.map((Uri uri) => uri.toString()), <String>[
        'bilibili://video/BV1xx411c7mD',
        'https://www.bilibili.com/video/BV1xx411c7mD',
      ]);
    });

    test('外部应用抛异常也回退浏览器', () async {
      final BilibiliOpenResult result = await openInApp(
        'BV1xx411c7mD',
        launchUrlFn: (Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) {
          if (uri.scheme == 'bilibili') {
            throw StateError('client not installed');
          }
          return Future<bool>.value(true);
        },
      );

      expect(result, BilibiliOpenResult.openedInBrowser);
    });

    test('客户端与浏览器都失败 → failed', () async {
      final BilibiliOpenResult result = await openInApp(
        'BV1xx411c7mD',
        launchUrlFn: (Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) {
          return Future<bool>.value(false);
        },
      );

      expect(result, BilibiliOpenResult.failed);
    });

    test('无效 bvid 不调起任何应用', () async {
      var called = false;
      final BilibiliOpenResult result = await openInApp(
        'https://b23.tv/abcd123',
        launchUrlFn: (Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) {
          called = true;
          return Future<bool>.value(true);
        },
      );

      expect(result, BilibiliOpenResult.failed);
      expect(called, isFalse);
    });
  });

  group('FeedPost.fromJson 兼容视频字段别名', () {
    test('video_url + videoId', () {
      final FeedPost post = FeedPost.fromJson(<String, dynamic>{
        'id': 'f1',
        'title': '标题',
        'author': '作者',
        'viewCount': 1,
        'publishedAt': '2026-01-01T00:00:00.000',
        'video_url': 'https://www.bilibili.com/video/BV1xx411c7mD',
        'videoId': 'BV1GJ411x7h7',
      });

      expect(post.videoUrl, 'https://www.bilibili.com/video/BV1xx411c7mD');
      expect(post.bvid, 'BV1GJ411x7h7');
    });

    test('url 与 bvid', () {
      final FeedPost post = FeedPost.fromJson(<String, dynamic>{
        'id': 'f2',
        'title': '标题',
        'author': '作者',
        'viewCount': 1,
        'publishedAt': '2026-01-01T00:00:00.000',
        'url': 'https://www.bilibili.com/video/BV1Xm4y1x7H8',
        'bvid': 'BV1Xm4y1x7H8',
      });

      expect(post.videoUrl, 'https://www.bilibili.com/video/BV1Xm4y1x7H8');
      expect(post.bvid, 'BV1Xm4y1x7H8');
    });

    test('没有视频字段时为 null', () {
      final FeedPost post = FeedPost.fromJson(<String, dynamic>{
        'id': 'f3',
        'title': '标题',
        'author': '作者',
        'viewCount': 1,
        'publishedAt': '2026-01-01T00:00:00.000',
      });

      expect(post.videoUrl, isNull);
      expect(post.bvid, isNull);
    });
  });
}
