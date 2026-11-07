import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/ui/ps_poster.dart';
import '../../catalog/domain/show_summary.dart';
import '../domain/feed_post.dart';
import '../feed_l10n.dart';
import '../../../shared/ui/ps_network_images.dart';

/// 发现流卡片（`home_item_waterfall_feed.xml`）。
///
/// 这是一张**深色卡**：黑色圆角 6dp 底、16:9 海报压住上半部分并在底部渐变成黑、
/// 黄色「网友热议」角标骑在海报下沿、白色 13dp 标题 2 行、
/// 底部 14dp 圆头像 + 10dp 白字作者 + 眼睛图标 + 浏览量。
///
/// 海报与渐变之间的层叠关系是这个卡片的识别特征，所以不用 `Card` + `ListTile`
/// 拼——那样会把角标压到海报里面去。
class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.post,
    this.show,
    this.onTap,
    this.onTapVideo,
  });

  final FeedPost post;

  /// 关联演出（用于海报与标题兜底）。
  final ShowSummary? show;

  final VoidCallback? onTap;

  /// 点击视频角标的回调；`null` 时角标只是装饰，点击落到卡片本身。
  final VoidCallback? onTapVideo;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final seed = show?.title ?? post.title;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  PsPoster(
                    seed: seed,
                    width: double.infinity,
                    height: double.infinity,
                    radius: 0,
                  ),
                  // gradient_65543c_to_000000：海报底部 20dp 压暗，让角标与标题有依托。
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 32,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0x00000000), Color(0xFF000000)],
                        ),
                      ),
                    ),
                  ),
                  if (post.hasVideo)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTapVideo,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0x66000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.play,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (post.tag != null)
                    Positioned(
                      left: 8,
                      bottom: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE600),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          post.tag!,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.1,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
              child: Row(
                children: <Widget>[
                  ClipOval(
                    child: Image.network(
                      PsImages.defaultAvatar,
                      width: 14,
                      height: 14,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 14,
                        height: 14,
                        color: colors.brandSubtle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      post.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(LucideIcons.eye, size: 11, color: colors.textTertiary),
                  const SizedBox(width: 2),
                  Text(
                    post.viewCountLabelOf(context),
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.1,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
