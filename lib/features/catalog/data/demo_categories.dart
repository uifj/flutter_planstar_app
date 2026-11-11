/// 品类目录：编译期常量（10 个一级品类 + 各自的二级标签）。
///
/// 产品定位是「企划支持平台」，品类围绕可被支持、可被交付的创意与经验内容：
/// 游戏 / 小说 / 同人 / 面经为四大主品类，其余为扩展品类。
/// 数据形状与服务端分类 JSON 一致，供首页 / 品类页 / 搜索筛选复用。
library;

import '../domain/show_category.dart';

const List<ShowCategory> demoCategories = <ShowCategory>[
  ShowCategory(
    id: 1,
    name: '游戏企划',
    enName: 'games',
    pinyin: 'youxiqihua',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 101, categoryId: 1, name: '独立游戏'),
      SubCategoryTag(id: 102, categoryId: 1, name: '解谜冒险'),
      SubCategoryTag(id: 103, categoryId: 1, name: '像素风'),
      SubCategoryTag(id: 104, categoryId: 1, name: '模拟经营'),
      SubCategoryTag(id: 105, categoryId: 1, name: '游戏试玩'),
      SubCategoryTag(id: 106, categoryId: 1, name: '联机合作'),
    ],
  ),
  ShowCategory(
    id: 2,
    name: '小说企划',
    enName: 'novels',
    pinyin: 'xiaoshuoqihua',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 201, categoryId: 2, name: '原创长篇'),
      SubCategoryTag(id: 202, categoryId: 2, name: '同人小说'),
      SubCategoryTag(id: 203, categoryId: 2, name: '悬疑推理'),
      SubCategoryTag(id: 204, categoryId: 2, name: '奇幻世界观'),
      SubCategoryTag(id: 205, categoryId: 2, name: '有声书'),
      SubCategoryTag(id: 206, categoryId: 2, name: '短篇集'),
    ],
  ),
  ShowCategory(
    id: 3,
    name: '同人企划',
    enName: 'fanworks',
    pinyin: 'tongrenqihua',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 301, categoryId: 3, name: '同人志'),
      SubCategoryTag(id: 302, categoryId: 3, name: '插画集'),
      SubCategoryTag(id: 303, categoryId: 3, name: '谷子周边'),
      SubCategoryTag(id: 304, categoryId: 3, name: '手办模型'),
      SubCategoryTag(id: 305, categoryId: 3, name: 'Cosplay'),
      SubCategoryTag(id: 306, categoryId: 3, name: '同人音乐'),
    ],
  ),
  ShowCategory(
    id: 4,
    name: '面经企划',
    enName: 'career',
    pinyin: 'mianjingqihua',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 401, categoryId: 4, name: '互联网面经'),
      SubCategoryTag(id: 402, categoryId: 4, name: '考公考编'),
      SubCategoryTag(id: 403, categoryId: 4, name: '考研留学'),
      SubCategoryTag(id: 404, categoryId: 4, name: '行业报告'),
      SubCategoryTag(id: 405, categoryId: 4, name: '求职训练营'),
      SubCategoryTag(id: 406, categoryId: 4, name: '简历模板'),
    ],
  ),
  ShowCategory(
    id: 5,
    name: '桌游企划',
    enName: 'boardgames',
    pinyin: 'zhuoyouqihua',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 501, categoryId: 5, name: '原创桌游'),
      SubCategoryTag(id: 502, categoryId: 5, name: '跑团模组'),
      SubCategoryTag(id: 503, categoryId: 5, name: '卡牌游戏'),
      SubCategoryTag(id: 504, categoryId: 5, name: '剧本杀'),
    ],
  ),
  ShowCategory(
    id: 6,
    name: '画集设定集',
    enName: 'artbooks',
    pinyin: 'huajishedingji',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 601, categoryId: 6, name: '画集'),
      SubCategoryTag(id: 602, categoryId: 6, name: '设定集'),
      SubCategoryTag(id: 603, categoryId: 6, name: '摄影集'),
      SubCategoryTag(id: 604, categoryId: 6, name: '绘本'),
    ],
  ),
  ShowCategory(
    id: 7,
    name: '音乐影像',
    enName: 'musicfilm',
    pinyin: 'yinyueyingxiang',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 701, categoryId: 7, name: '原创专辑'),
      SubCategoryTag(id: 702, categoryId: 7, name: '同人音乐'),
      SubCategoryTag(id: 703, categoryId: 7, name: '播客'),
      SubCategoryTag(id: 704, categoryId: 7, name: '动画短片'),
    ],
  ),
  ShowCategory(
    id: 8,
    name: '校园与活动',
    enName: 'campus',
    pinyin: 'xiaoyuanhuodong',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 801, categoryId: 8, name: '校园社团'),
      SubCategoryTag(id: 802, categoryId: 8, name: '毕业设计'),
      SubCategoryTag(id: 803, categoryId: 8, name: '线下见面会'),
      SubCategoryTag(id: 804, categoryId: 8, name: '试玩会'),
    ],
  ),
  ShowCategory(
    id: 9,
    name: '其他企划',
    enName: 'others',
    pinyin: 'qitaqihua',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 901, categoryId: 9, name: '创意出版'),
      SubCategoryTag(id: 902, categoryId: 9, name: '手作'),
      SubCategoryTag(id: 903, categoryId: 9, name: '公益创意'),
      SubCategoryTag(id: 904, categoryId: 9, name: '其他'),
    ],
  ),
  ShowCategory(
    id: 10,
    name: '自媒体企划',
    enName: 'selfmedia',
    pinyin: 'zimeitiqihua',
    status: 1,
    subTags: <SubCategoryTag>[
      SubCategoryTag(id: 1001, categoryId: 10, name: '短视频栏目'),
      SubCategoryTag(id: 1002, categoryId: 10, name: '图文专栏'),
      SubCategoryTag(id: 1003, categoryId: 10, name: '直播企划'),
      SubCategoryTag(id: 1004, categoryId: 10, name: '知识专栏'),
      SubCategoryTag(id: 1005, categoryId: 10, name: '播客节目'),
      SubCategoryTag(id: 1006, categoryId: 10, name: '社群共创'),
    ],
  ),
];
