/// 分类目录：编译期常量（8 个一级分类 + 各自的二级标签）。
///
/// 本地 `assets/` 已整体移除，分类不再运行时读资源文件；
/// 数据形状与原 JSON 配置一致，供首页 / 分类页 / 搜索筛选复用。
library;

import '../domain/show_category.dart';

const List<ShowCategory> demoCategories = <ShowCategory>[
  ShowCategory(
    id: 1,
    name: '演唱会',
    enName: 'concerts',
    pinyin: 'yanchanghui',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 1, categoryId: 1, name: '演唱会'),
      SubCategoryTag(id: 3, categoryId: 1, name: 'Live&Club'),
      SubCategoryTag(id: 2, categoryId: 1, name: '音乐节'),
      SubCategoryTag(id: 104, categoryId: 1, name: '巡演'),
      SubCategoryTag(id: 4, categoryId: 1, name: '见面会'),
    ],
  ),
  ShowCategory(
    id: 8,
    name: '体育赛事',
    enName: 'sports',
    pinyin: 'tiyusaishi',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 14, categoryId: 8, name: '足球'),
      SubCategoryTag(id: 18, categoryId: 8, name: '电竞'),
      SubCategoryTag(id: 15, categoryId: 8, name: '篮球'),
    ],
  ),
  ShowCategory(
    id: 2,
    name: '话剧歌剧',
    enName: 'dramas',
    pinyin: 'huajugeju',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 7, categoryId: 2, name: '话剧'),
      SubCategoryTag(id: 8, categoryId: 2, name: '音乐剧'),
      SubCategoryTag(id: 147, categoryId: 2, name: '舞剧'),
      SubCategoryTag(id: 153, categoryId: 2, name: '舞台剧'),
      SubCategoryTag(id: 79, categoryId: 2, name: '喜剧'),
      SubCategoryTag(id: 11, categoryId: 2, name: '沉浸式戏剧'),
      SubCategoryTag(id: 149, categoryId: 2, name: '儿童剧'),
      SubCategoryTag(id: 13, categoryId: 2, name: '其他'),
      SubCategoryTag(id: 10, categoryId: 2, name: '放映'),
      SubCategoryTag(id: 100, categoryId: 2, name: '法语音乐剧'),
      SubCategoryTag(id: 9, categoryId: 2, name: '歌剧'),
      SubCategoryTag(id: 150, categoryId: 2, name: '亲子剧'),
    ],
  ),
  ShowCategory(
    id: 3,
    name: '音乐会',
    enName: 'musicale',
    pinyin: 'yinyuehui',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 42, categoryId: 3, name: '音乐会'),
      SubCategoryTag(id: 152, categoryId: 3, name: '交响乐'),
      SubCategoryTag(id: 91, categoryId: 3, name: '钢琴'),
      SubCategoryTag(id: 69, categoryId: 3, name: '合唱'),
      SubCategoryTag(id: 87, categoryId: 3, name: '小提琴'),
      SubCategoryTag(id: 106, categoryId: 3, name: '室内乐'),
    ],
  ),
  ShowCategory(
    id: 7,
    name: '戏曲综艺',
    enName: 'shows',
    pinyin: 'xiquzongyi',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 45, categoryId: 7, name: '脱口秀'),
      SubCategoryTag(id: 35, categoryId: 7, name: '戏曲'),
      SubCategoryTag(id: 34, categoryId: 7, name: '相声'),
      SubCategoryTag(id: 146, categoryId: 7, name: '越剧'),
      SubCategoryTag(id: 38, categoryId: 7, name: '其他'),
      SubCategoryTag(id: 151, categoryId: 7, name: '京剧'),
      SubCategoryTag(id: 37, categoryId: 7, name: '魔术'),
    ],
  ),
  ShowCategory(
    id: 4,
    name: '儿童亲子',
    enName: 'family',
    pinyin: 'ertongqingzi',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 39, categoryId: 4, name: '儿童剧'),
      SubCategoryTag(id: 92, categoryId: 4, name: '亲子舞台剧'),
      SubCategoryTag(id: 41, categoryId: 4, name: '其他'),
      SubCategoryTag(id: 40, categoryId: 4, name: '亲子活动'),
      SubCategoryTag(id: 103, categoryId: 4, name: '亲子音乐剧'),
    ],
  ),
  ShowCategory(
    id: 5,
    name: '休闲展览',
    enName: 'exhibits',
    pinyin: 'xiuxianzhanlan',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 21, categoryId: 5, name: '展览'),
      SubCategoryTag(id: 28, categoryId: 5, name: '其他'),
    ],
  ),
  ShowCategory(
    id: 6,
    name: '舞蹈芭蕾',
    enName: 'dance',
    pinyin: 'wudaobalei',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 32, categoryId: 6, name: '舞剧'),
      SubCategoryTag(id: 29, categoryId: 6, name: '芭蕾舞'),
      SubCategoryTag(id: 117, categoryId: 6, name: '现代舞'),
      SubCategoryTag(id: 30, categoryId: 6, name: '当代舞'),
    ],
  ),
];
