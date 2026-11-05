// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '企划星';

  @override
  String get tabHome => '首页';

  @override
  String get tabDiscover => '发现';

  @override
  String get tabMessage => '消息';

  @override
  String get tabOrder => '订单';

  @override
  String get tabProfile => '我的';

  @override
  String get actionRetry => '重试';

  @override
  String get actionCancel => '取消';

  @override
  String get actionConfirm => '确定';

  @override
  String get actionSave => '保存';

  @override
  String get stateLoading => '加载中…';

  @override
  String get stateEmpty => '暂无内容';

  @override
  String get stateNetworkError => '网络不给力，请稍后重试';

  @override
  String get stateTimeout => '请求超时，请重试';

  @override
  String get stateUnauthorized => '登录已失效，请重新登录';

  @override
  String get stateOfflineCache => '当前展示的是离线缓存内容';
}
