import '../domain/feed_post.dart';

/// 演示社区动态。
///
/// 企划星的发现页数据来自 feed 接口（`v1/feed/list`），带图文/视频/演出卡三种类型。
/// 视频动态只补 bvid / 视频页链接，不造 CDN 地址——播放交给哔哩哔哩官方页，
/// 真实可验证，也不会出现"链接过期"的假象。
///
/// 时间相对"今天"生成，保证列表里出现"3小时前""昨天"这类真实时间文案。
List<FeedPost> buildDemoFeed({DateTime? now}) {
  final reference = now ?? DateTime.now();

  FeedPost post({
    required String id,
    required String title,
    required String author,
    required int viewCount,
    required Duration ago,
    required String body,
    String? tag,
    String? showId,
    int likeCount = 0,
    bool hasVideo = false,
    String? videoUrl,
    String? bvid,
  }) {
    return FeedPost(
      id: id,
      title: title,
      author: author,
      viewCount: viewCount,
      publishedAt: reference.subtract(ago),
      tag: tag,
      showId: showId,
      likeCount: likeCount,
      hasVideo: hasVideo,
      body: body,
      videoUrl: videoUrl,
      bvid: bvid,
    );
  }

  return <FeedPost>[
    post(
      id: 'f1',
      title: '《星海回声》首映repo：灯光落下的那一刻全场屏住呼吸',
      author: '企划常驻民',
      viewCount: 32_400,
      ago: const Duration(hours: 3),
      tag: '网友热议',
      showId: '2001',
      likeCount: 1_208,
      body:
          '序曲一响就知道这版是认真的。吊灯升起的段落用的是原版机械结构，'
          '从头顶掠过时能听到轨道滑动的声音。\n\n'
          '中文唱词比我预期自然，几个关键段落没有被翻译腔拖住。'
          '二层楼座中区是性价比最高的位置，能同时看到乐池和舞台深度。',
    ),
    post(
      id: 'f2',
      title: '夏日回声企划支持攻略：这三个时间点最容易捡漏',
      author: '支持小分队',
      viewCount: 128_000,
      ago: const Duration(hours: 5),
      tag: '攻略',
      showId: '1001',
      likeCount: 4_560,
      hasVideo: true,
      // 完整 URL + 查询参数：验证 `extractBvid` 从链接里归一 bvid。
      videoUrl:
          'https://www.bilibili.com/video/BV1MU4pzAEyy/?spm_id_from=333.788',
      body:
          '开放支持后 15 分钟、支持截止前 7 天、支持截止前 48 小时——'
          '这三个时间点是取消支持回流最集中的窗口。\n\n'
          '前两个靠蹲，第三个靠"回流提醒"。'
          '另外内场 A 区靠后的位置其实视野被前区挡住，别为了区域名多花钱。',
    ),
    post(
      id: 'f3',
      title: 'teamLab 无界美术馆拍照机位整理，附最佳入场时间',
      author: '看展的猫',
      viewCount: 18_600,
      ago: const Duration(hours: 8),
      tag: '体验repo',
      showId: '5001',
      likeCount: 902,
      body:
          '工作日上午 10 点第一场人最少，光影馆基本能空场拍。\n\n'
          '推荐机位：镜像球体区（低角度）、水晶宇宙（贴近地面仰拍）、'
          '以及出口前的花与人房间。手机记得关自动测光，不然会过曝。',
    ),
    post(
      id: 'f4',
      title: '第一次看《不眠之夜》，跟着演员跑了三层楼，值回票价',
      author: '沉浸式爱好者',
      viewCount: 9_800,
      ago: const Duration(hours: 11),
      tag: '网友热议',
      showId: '2004',
      likeCount: 431,
      body:
          '面具戴上之后没人说话，全靠眼神和跟随。建议第一轮先跟着主线，'
          '第二轮再单独追一个角色——不然会在楼梯间迷路。\n\n'
          '穿好走的鞋，全程三小时基本在站和走。',
    ),
    post(
      id: 'f5',
      title: '上海文化中心选座指南：楼座 2 层其实比池座后排看得清',
      author: '选座研究所',
      viewCount: 24_100,
      ago: const Duration(days: 1),
      tag: '攻略',
      showId: '2002',
      likeCount: 1_540,
      body:
          '文化中心的池座后排有遮挡，楼座 2 层虽然远但视线完整，'
          '而且票价比池座后排低一档。\n\n'
          '看话剧优先选正对舞台的楼座 1 层前区；看舞剧选偏一点的侧区，'
          '因为调度会用到舞台深处。',
    ),
    post(
      id: 'f6',
      title: '五月天现场｜25 年了，合唱《温柔》的时候还是想哭',
      author: '阿信的迷妹',
      viewCount: 76_500,
      ago: const Duration(days: 1, hours: 4),
      tag: '网友热议',
      showId: '1002',
      likeCount: 3_320,
      hasVideo: true,
      // 裸 bvid：五月天鸟巢《温柔》合唱现场。
      bvid: 'BV1Xm4y1x7H8',
      body:
          '安可第三首才是《温柔》，全场自动打开手机灯。\n\n'
          '内场站区很挤，体力不好的建议看台。音响这次调得不错，'
          '低音没有糊。',
    ),
    post(
      id: 'f7',
      title: '带孩子看《故宫里的大怪兽》前，先读一遍绘本会更好',
      author: '两个娃的妈',
      viewCount: 6_400,
      ago: const Duration(days: 2),
      tag: '亲子',
      showId: '4001',
      likeCount: 288,
      body:
          '读过绘本的孩子能认出角色，全程注意力明显更集中。\n\n'
          '现场 70 分钟没有中场，5 岁以下建议坐靠走道的位置，'
          '方便中途出去。',
    ),
    post(
      id: 'f8',
      title: '中超德比观赛体验：浦东足球场的声浪是真的顶',
      author: '看台第十二人',
      viewCount: 12_900,
      ago: const Duration(days: 2, hours: 6),
      tag: '体验repo',
      showId: '8001',
      likeCount: 640,
      body:
          '主场看台的助威是有组织的，跟着喊两轮就上手了。\n\n'
          '散场地铁比想象中快，建议走 2 号口。',
    ),
    post(
      id: 'f9',
      title: '《巴黎圣母院》法语原版：大教堂时代一响，鸡皮疙瘩起来了',
      author: '音乐剧搬运工',
      viewCount: 15_700,
      ago: const Duration(days: 3),
      tag: '网友热议',
      showId: '2003',
      likeCount: 812,
      body:
          '开场《大教堂时代》的合唱层次比录音版更厚，'
          '现场乐队的铜管是加分项。\n\n'
          '字幕屏位置偏高，坐前区需要抬头，介意的话选后区。',
    ),
    post(
      id: 'f10',
      title: '脱口秀现场和线上完全两种体验，笑到腮帮子疼',
      author: '段子收集器',
      viewCount: 8_200,
      ago: const Duration(days: 3, hours: 8),
      tag: '体验repo',
      showId: '7002',
      likeCount: 356,
      body:
          '线上的段子到了现场有一半是新的，互动环节才是主场优势。\n\n'
          '前排会被点名，社恐请坐中后区。',
    ),
    post(
      id: 'f11',
      title: '马林斯基《天鹅湖》32 个挥鞭转，现场掌声持续了两分钟',
      author: '芭蕾笔记',
      viewCount: 21_300,
      ago: const Duration(days: 4),
      tag: '体验repo',
      showId: '6001',
      likeCount: 1_102,
      body:
          '黑天鹅双人舞的挥鞭转是全场顶点，乐团跟着加快了半拍。\n\n'
          '看芭蕾建议选侧前方，能看清足尖和手臂线条。',
    ),
    post(
      id: 'f12',
      title: '德云社上海专场：郭德纲一开口，全场就开始接梗',
      author: '相声票友',
      viewCount: 44_800,
      ago: const Duration(days: 4, hours: 9),
      tag: '网友热议',
      showId: '7001',
      likeCount: 2_204,
      body:
          '返场比正活还长，观众接梗接得比演员还快。\n\n'
          '园子小，最后一排也听得清，不用抢前排。',
    ),
    post(
      id: 'f13',
      title: '维也纳爱乐来了，这次曲目单里有一首很少演的布鲁克纳',
      author: '古典乐手记',
      viewCount: 5_600,
      ago: const Duration(days: 5),
      tag: '攻略',
      showId: '3001',
      likeCount: 240,
      body:
          '布鲁克纳第七的慢乐章是这场的关键，'
          '建议提前听两遍再进场，现场的信息量会大很多。\n\n'
          '乐章之间不要鼓掌，这是这类音乐会的基本礼仪。',
    ),
    post(
      id: 'f14',
      title: '简单生活节两天全记录：哪个舞台值得蹲一整天',
      author: '音乐节地图',
      viewCount: 33_100,
      ago: const Duration(days: 5, hours: 7),
      tag: '攻略',
      showId: '1004',
      likeCount: 1_680,
      hasVideo: true,
      body:
          '主舞台压轴之外，第二天下午的微风舞台是隐藏彩蛋。\n\n'
          '两天通票比单日划算，但体力要留够。草地早晚温差大，带件外套。',
    ),
    post(
      id: 'f15',
      title: 'LPL 春季赛现场：解说声音比直播间大十倍',
      author: '召唤师峡谷',
      viewCount: 51_200,
      ago: const Duration(days: 6),
      tag: '体验repo',
      showId: '8002',
      likeCount: 2_460,
      body:
          '大屏导播切得比直播快，团战能提前半秒看到结果。\n\n'
          '场馆内餐饮偏贵，建议提前吃。',
    ),
    post(
      id: 'f16',
      title: '《恋爱的犀牛》看了三遍，每次都在同一句台词掉眼泪',
      author: '小剧场常客',
      viewCount: 4_100,
      ago: const Duration(days: 7),
      tag: '体验repo',
      showId: '2005',
      likeCount: 198,
      body:
          '"你是我温暖的手套，冰冷的啤酒"——这句一出来就没绷住。\n\n'
          '小剧场第一排会有互动，想安静看戏的选后排。',
    ),
    post(
      id: 'f17',
      title: '久石让音乐会亲子场：孩子全程没走神，这就够了',
      author: '周末带娃',
      viewCount: 7_300,
      ago: const Duration(days: 8),
      tag: '亲子',
      showId: '3003',
      likeCount: 312,
      body:
          '曲目选了《千与千寻》《龙猫》这些熟悉的段落，孩子能跟上。\n\n'
          '亲子场允许小声说话，不用担心被侧目，这点很友好。',
    ),
    post(
      id: 'f18',
      title: '印象莫奈展：投影区比静态展区好看太多',
      author: '看展的猫',
      viewCount: 3_800,
      ago: const Duration(days: 9),
      tag: '体验repo',
      showId: '5002',
      likeCount: 146,
      body:
          '投影区大概 20 分钟一轮，建议进去就坐下等完整一轮。\n\n'
          '静态展区的真迹不多，主要看氛围。',
    ),
    post(
      id: 'f19',
      title: '陈奕迅 FEAR AND DREAMS：舞台设计是这几年最好的',
      author: '港乐三十年',
      viewCount: 62_700,
      ago: const Duration(days: 10),
      tag: '网友热议',
      showId: '1003',
      likeCount: 2_980,
      hasVideo: true,
      body:
          '舞台是环绕式投影，四面台都能看到完整视觉。\n\n'
          '歌单偏后期作品，想听老歌的要有心理准备。',
    ),
    post(
      id: 'f20',
      title: '上海京昆艺术中心折子戏：80 块能看到这个水平，太值了',
      author: '戏迷老王',
      viewCount: 2_400,
      ago: const Duration(days: 12),
      tag: '体验repo',
      showId: '7003',
      likeCount: 88,
      body:
          '三折戏里《三岔口》的哑剧段落最精彩，全靠身段。\n\n'
          '剧场不大，最后一排也看得清脸谱。',
    ),
  ];
}

/// 演示评论。
///
/// 企划星的评论走独立接口（`v1/feed/comment/list`），按动态 id 分页。
/// 这里只给前几条动态造评论，**其余返回空**——空评论区是真实存在的一屏，
/// 给它塞假评论会让"这条动态没人讨论"这个信息消失。
List<FeedComment> buildDemoComments(String postId, {DateTime? now}) {
  final reference = now ?? DateTime.now();

  FeedComment comment({
    required String id,
    required String author,
    required String text,
    required Duration ago,
    int likeCount = 0,
  }) {
    return FeedComment(
      id: id,
      author: author,
      text: text,
      publishedAt: reference.subtract(ago),
      likeCount: likeCount,
    );
  }

  return switch (postId) {
    'f1' => <FeedComment>[
      comment(
        id: 'c1-1',
        author: '剧场钉子户',
        text: '同场！吊灯那段我旁边的观众直接"哇"出声了。',
        ago: const Duration(minutes: 42),
        likeCount: 36,
      ),
      comment(
        id: 'c1-2',
        author: '第一次看音乐剧',
        text: '请问二楼楼座的字幕看得清吗？在犹豫买哪一档。',
        ago: const Duration(hours: 2),
        likeCount: 8,
      ),
      comment(
        id: 'c1-3',
        author: '企划常驻民',
        text: '楼座中区没问题，边角位会挡到一点。',
        ago: const Duration(hours: 1),
        likeCount: 21,
      ),
    ],
    'f2' => <FeedComment>[
      comment(
        id: 'c2-1',
        author: '抢到票的人',
        text: '开演前 48 小时那条是真的，我就是这么捡到的。',
        ago: const Duration(hours: 3),
        likeCount: 64,
      ),
      comment(
        id: 'c2-2',
        author: '陪跑三年',
        text: '回流提醒在哪里设置？没找到入口。',
        ago: const Duration(hours: 4),
        likeCount: 12,
      ),
    ],
    'f3' => <FeedComment>[
      comment(
        id: 'c3-1',
        author: '拍照的鱼',
        text: '水晶宇宙真的要好早去，晚了全是人头。',
        ago: const Duration(hours: 6),
        likeCount: 19,
      ),
    ],
    'f5' => <FeedComment>[
      comment(
        id: 'c5-1',
        author: '话剧爱好者',
        text: '楼座 2 层视野确实完整，就是离得远，看表情有点勉强。',
        ago: const Duration(hours: 20),
        likeCount: 27,
      ),
      comment(
        id: 'c5-2',
        author: '选座研究所',
        text: '看表情的话选楼座 1 层前区，价格差不太多。',
        ago: const Duration(hours: 18),
        likeCount: 15,
      ),
    ],
    _ => const <FeedComment>[],
  };
}
