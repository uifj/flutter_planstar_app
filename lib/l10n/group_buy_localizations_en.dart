// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'group_buy_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GroupBuyLocalizationsEn extends GroupBuyLocalizations {
  GroupBuyLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get groupBuy_72 => '超低价拼团';

  @override
  String groupBuy_144(Object rate) {
    return '$rate折';
  }

  @override
  String groupBuy_145(Object rate) {
    return '$rate折';
  }

  @override
  String get groupBuy_155 => '拼团中';

  @override
  String get groupBuy_157 => '拼团成功';

  @override
  String get groupBuy_159 => '拼团失败';

  @override
  String get groupBuy_161 => '已取消';

  @override
  String get groupBuyDetailPage_46 => '拼团详情';

  @override
  String get groupBuyDetailPage_49 => '拼团活动不存在';

  @override
  String get groupBuyDetailPage_60 => '拼团详情';

  @override
  String get groupBuyDetailPage_172 => '拼团价 ';

  @override
  String groupBuyDetailPage_208(Object savedAmount) {
    return '省$savedAmount';
  }

  @override
  String groupBuyDetailPage_249(Object succeedNum) {
    return '$succeedNum人成团';
  }

  @override
  String get groupBuyDetailPage_259 => '已满团';

  @override
  String groupBuyDetailPage_259_2(Object remaining) {
    return '还差$remaining人';
  }

  @override
  String groupBuyDetailPage_283(Object remainingHours) {
    return '剩余 $remainingHours 小时';
  }

  @override
  String groupBuyDetailPage_316(Object currentMembers, Object succeedNum) {
    return '参团成员 ($currentMembers/$succeedNum)';
  }

  @override
  String get groupBuyDetailPage_394 => '团长';

  @override
  String get groupBuyDetailPage_444 => '待邀请';

  @override
  String get groupBuyDetailPage_472 => '拼团规则';

  @override
  String get groupBuyDetailPage_481 => '1. 在有效期内邀请好友参团，满人数即成团\n2. 拼团成功后系统自动出票\n3. 未在有效期内满团则自动退款\n4. 每人限参 1 个拼团\n5. 拼团价不与其他优惠叠加';

  @override
  String get groupBuyDetailPage_533 => '拼团价';

  @override
  String get groupBuyDetailPage_573 => '立即参团';

  @override
  String get groupBuyPage_28 => '超低价拼团';

  @override
  String get groupBuyPage_31 => '暂无拼团活动';

  @override
  String get groupBuyPage_32 => '拼团活动上线后会显示在这里';

  @override
  String get groupBuyPage_150 => '拼团价 ';

  @override
  String groupBuyPage_210(Object currentMembers, Object succeedNum) {
    return '$currentMembers/$succeedNum人';
  }

  @override
  String get groupBuyProviders_59 => '参团成功！等待拼团完成';
}
