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
  String get groupBuyDetailPage_481 => '1. Invite friends to join before the deadline; the group forms when the required number is reached\n2. A support voucher is generated automatically once the group succeeds\n3. If the group is not filled before the deadline, the payment is refunded automatically\n4. Each person can join only one group per campaign\n5. Group-buy prices cannot be combined with other offers';

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
