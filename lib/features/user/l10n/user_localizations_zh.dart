// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'user_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class UserLocalizationsZh extends UserLocalizations {
  UserLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get userTitle => '我的';

  @override
  String userLoggedIn(String nickname) {
    return '已登录：$nickname';
  }

  @override
  String get userNotLoggedIn => '未登录';

  @override
  String get userLogout => '退出登录';

  @override
  String get userMockLogin => '模拟登录';

  @override
  String get userViewOrders => '查看订单（受门禁保护）';
}
