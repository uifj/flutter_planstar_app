// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'user_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class UserLocalizationsEn extends UserLocalizations {
  UserLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get userTitle => 'Me';

  @override
  String userLoggedIn(String nickname) {
    return 'Signed in as $nickname';
  }

  @override
  String get userNotLoggedIn => 'Not signed in';

  @override
  String get userLogout => 'Sign out';

  @override
  String get userMockLogin => 'Mock sign-in';

  @override
  String get userViewOrders => 'View orders (gated)';

  @override
  String get addressPage_49 => '收货地址';

  @override
  String get addressPage_55 => '还没有收货地址';

  @override
  String get addressPage_56 => '寄送线下回报时需要地址，先添加一个吧';

  @override
  String get addressPage_58 => '新增地址';

  @override
  String get addressPage_131 => '删除地址';

  @override
  String addressPage_132(Object name, Object maskedMobile) {
    return '确定删除「$name $maskedMobile」这个地址吗？';
  }

  @override
  String get addressPage_140 => '删除';

  @override
  String get addressPage_150 => '已删除';

  @override
  String get addressPage_211 => '默认';

  @override
  String get addressPage_263 => '默认地址';

  @override
  String get addressPage_263_2 => '设为默认';

  @override
  String get addressPage_276 => '编辑';

  @override
  String get addressPage_278 => '删除';

  @override
  String get addressPage_349 => '新增地址';

  @override
  String get addressPage_472 => '编辑地址';

  @override
  String get addressPage_472_2 => '新增地址';

  @override
  String get addressPage_493 => '收件人';

  @override
  String get addressPage_494 => '真实姓名';

  @override
  String get addressPage_500 => '手机号';

  @override
  String get addressPage_501 => '11 位手机号';

  @override
  String get addressPage_511 => '所在地区';

  @override
  String get addressPage_512 => '省 市 区（如：上海市 浦东新区）';

  @override
  String get addressPage_517 => '详细地址';

  @override
  String get addressPage_518 => '街道、门牌号、回报领取点';

  @override
  String get profileProviders_58 => '登录更精彩';

  @override
  String profileProviders_86(Object level) {
    return 'V$level 资深支持人';
  }

  @override
  String get editProfilePage_65 => '编辑资料';

  @override
  String get editProfilePage_75 => '头像上传待接入';

  @override
  String get editProfilePage_107 => '点击更换头像';

  @override
  String get editProfilePage_116 => '昵称';

  @override
  String get editProfilePage_140 => '性别';

  @override
  String get editProfilePage_145 => '保密';

  @override
  String get editProfilePage_151 => '男';

  @override
  String get editProfilePage_157 => '女';

  @override
  String get editProfilePage_165 => '个性签名';

  @override
  String get editProfilePage_180 => '写点什么介绍自己吧…';

  @override
  String get editProfilePage_229 => '资料已记录（演示模式，未实际提交到服务器）';

  @override
  String get feedbackPage_32 => '功能建议';

  @override
  String get feedbackPage_33 => '企划问题';

  @override
  String get feedbackPage_34 => '支付问题';

  @override
  String get feedbackPage_35 => '支持体验';

  @override
  String get feedbackPage_36 => '其他';

  @override
  String get feedbackPage_58 => '意见反馈';

  @override
  String get feedbackPage_66 => '反馈类型';

  @override
  String get feedbackPage_114 => '反馈内容';

  @override
  String get feedbackPage_123 => '请至少填写 10 个字，以便我们更好地理解您的问题';

  @override
  String get feedbackPage_140 => '请描述您遇到的问题或建议…';

  @override
  String get feedbackPage_160 => '联系方式（选填）';

  @override
  String get feedbackPage_169 => '留下手机号或邮箱，方便我们与您联系';

  @override
  String get feedbackPage_184 => '手机号 / 邮箱';

  @override
  String get feedbackPage_211 => '提交反馈';

  @override
  String get feedbackPage_230 => '反馈已记录（演示模式，未实际提交到服务器）';

  @override
  String get settingsPage_53 => '设置';

  @override
  String get settingsPage_60 => '昵称';

  @override
  String get settingsPage_64 => '请先登录';

  @override
  String get settingsPage_67 => '手机号';

  @override
  String get settingsPage_68 => '未绑定';

  @override
  String get settingsPage_69 => '换绑手机号需要先验证原手机号';

  @override
  String get settingsPage_72 => '意见反馈';

  @override
  String get settingsPage_76 => '实名认证';

  @override
  String get settingsPage_77 => '未认证';

  @override
  String get settingsPage_79 => '实名认证属于独立的 id 聚合，本示例未实现';

  @override
  String get settingsPage_86 => '消息通知';

  @override
  String get settingsPage_95 => '深色模式';

  @override
  String get settingsPage_107 => '清除缓存';

  @override
  String get settingsPage_108 => '图片与接口缓存';

  @override
  String get settingsPage_110 => '缓存清理待接入 package:core/cache.dart 的 HttpCacheStore';

  @override
  String get settingsPage_117 => '版本号';

  @override
  String get settingsPage_119 => '已是最新版本';

  @override
  String get settingsPage_122 => '用户协议';

  @override
  String get settingsPage_123 => '协议页待接入 WebView（`web` 包 64 个类的等价物）';

  @override
  String get settingsPage_126 => '隐私政策';

  @override
  String get settingsPage_128 => '隐私政策页待接入 WebView';

  @override
  String get settingsPage_162 => '跟随系统';

  @override
  String get settingsPage_164 => '开启';

  @override
  String get settingsPageDarkModeOff => '关闭';

  @override
  String get settingsPage_172 => '退出后需要重新登录才能查看订单，确定继续吗？';

  @override
  String get settingsPage_180 => '退出';

  @override
  String get settingsPage_188 => '已退出登录';

  @override
  String get userPage_67 => '个人主页不在本次范围内';

  @override
  String get userPage_81 => '支持人管理待接入，敬请期待';

  @override
  String get userPage_82 => '客服会话（演示）';

  @override
  String get userPage_83 => '卖家招募不在本次范围内';

  @override
  String get userPage_98 => '已退出登录';

  @override
  String get userPage_254 => '点击登录，查看订单与优惠券';

  @override
  String get userPage_308 => '个人主页';

  @override
  String get userPage_333 => '支持过';

  @override
  String get userPage_340 => '关注';

  @override
  String get userPage_483 => '全部支持';

  @override
  String get userPage_569 => '优惠券';

  @override
  String get userPage_580 => '我的钱包';

  @override
  String get userPage_650 => '礼品卡';

  @override
  String get userPage_651 => '代购服务';

  @override
  String get userPage_652 => '超低价拼团';

  @override
  String get userPage_653 => '地址管理';

  @override
  String get userPage_654 => '支持人';

  @override
  String get userPage_655 => '联系客服';

  @override
  String get userPage_656 => '卖家招募';
}
