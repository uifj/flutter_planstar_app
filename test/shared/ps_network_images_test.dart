import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/features/catalog/data/demo_categories.dart';
import 'package:planstar/shared/ui/ps_network_images.dart';

/// 图片不走本地 `assets/`：这里覆盖网络图源 URL 与编译期分类常量两类入口。
void main() {
  test('PsImages 生成确定性的开源免费图床 URL', () {
    expect(PsImages.poster('剧院魅影'), PsImages.poster('剧院魅影'));
    expect(PsImages.poster('剧院魅影'), contains('picsum.photos'));
    expect(PsImages.avatar('u1'), contains('picsum.photos'));
    expect(PsImages.defaultAvatar, contains('picsum.photos'));
    // 不同 seed 必须拿到不同图片，否则所有海报会长一模一样。
    expect(PsImages.poster('a'), isNot(PsImages.poster('b')));
  });

  test('分类常量：10 个上架一级分类且都带二级标签', () {
    expect(demoCategories.length, 10);
    expect(demoCategories.every((c) => c.isActive), isTrue);
    expect(demoCategories.every((c) => c.subTags.isNotEmpty), isTrue);
  });
}
