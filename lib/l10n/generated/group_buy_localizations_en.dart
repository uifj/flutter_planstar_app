// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'group_buy_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GroupBuyLocalizationsEn extends GroupBuyLocalizations {
  GroupBuyLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get groupBuy_72 => 'Ultra-low Price Group Buying';

  @override
  String groupBuy_144(Object rate) {
    return '$rate% off';
  }

  @override
  String groupBuy_145(Object rate) {
    return '$rate% off';
  }

  @override
  String get groupBuy_155 => 'In Progress';

  @override
  String get groupBuy_157 => 'Succeeded';

  @override
  String get groupBuy_159 => 'Failed';

  @override
  String get groupBuy_161 => 'Cancelled';

  @override
  String get groupBuyDetailPage_46 => 'Group Buying Details';

  @override
  String get groupBuyDetailPage_49 => 'Group buying event not found';

  @override
  String get groupBuyDetailPage_60 => 'Group Buying Details';

  @override
  String get groupBuyDetailPage_172 => 'Group price ';

  @override
  String groupBuyDetailPage_208(Object savedAmount) {
    return 'Save $savedAmount';
  }

  @override
  String groupBuyDetailPage_249(Object succeedNum) {
    return '$succeedNum people needed to form a group';
  }

  @override
  String get groupBuyDetailPage_259 => 'Group Full';

  @override
  String groupBuyDetailPage_259_2(Object remaining) {
    return '$remaining more people needed';
  }

  @override
  String groupBuyDetailPage_283(Object remainingHours) {
    return '$remainingHours hours left';
  }

  @override
  String groupBuyDetailPage_316(Object currentMembers, Object succeedNum) {
    return 'Group Members ($currentMembers/$succeedNum)';
  }

  @override
  String get groupBuyDetailPage_394 => 'Leader';

  @override
  String get groupBuyDetailPage_444 => 'Pending';

  @override
  String get groupBuyDetailPage_472 => 'Group Buying Rules';

  @override
  String get groupBuyDetailPage_481 => '1. Invite friends to join before the deadline; the group forms when the required number is reached\n2. A support voucher is generated automatically once the group succeeds\n3. If the group is not filled before the deadline, the payment is refunded automatically\n4. Each person can join only one group per campaign\n5. Group-buy prices cannot be combined with other offers';

  @override
  String get groupBuyDetailPage_533 => 'Group Price';

  @override
  String get groupBuyDetailPage_573 => 'Join Now';

  @override
  String get groupBuyPage_28 => 'Ultra-low Price Group Buying';

  @override
  String get groupBuyPage_31 => 'No group buying events yet';

  @override
  String get groupBuyPage_32 => 'Group buying events will appear here once available';

  @override
  String get groupBuyPage_150 => 'Group price ';

  @override
  String groupBuyPage_210(Object currentMembers, Object succeedNum) {
    return '$currentMembers/$succeedNum people';
  }

  @override
  String get groupBuyProviders_59 => 'Joined successfully! Waiting for the group to complete';
}
