import 'package:flutter/material.dart';
import 'package:planstar/app/app.dart';
import 'package:planstar/l10n/auth_localizations.dart';
import 'package:planstar/l10n/catalog_localizations.dart';
import 'package:planstar/l10n/discover_localizations.dart';
import 'package:planstar/l10n/goods_localizations.dart';
import 'package:planstar/l10n/group_buy_localizations.dart';
import 'package:planstar/l10n/home_localizations.dart';
import 'package:planstar/l10n/marketing_localizations.dart';
import 'package:planstar/l10n/message_localizations.dart';
import 'package:planstar/l10n/order_localizations.dart';
import 'package:planstar/l10n/proxy_buy_localizations.dart';
import 'package:planstar/l10n/search_localizations.dart';
import 'package:planstar/l10n/user_localizations.dart';
import 'package:planstar/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// 每套 l10n 的「探针」：取一个一定存在的文案，用来证明该类真的被加载了。
final Map<String, LocalizationsDelegate<Object>> _delegates =
    <String, LocalizationsDelegate<Object>>{
  'app': AppLocalizations.delegate,
  'auth': AuthLocalizations.delegate,
  'catalog': CatalogLocalizations.delegate,
  'discover': DiscoverLocalizations.delegate,
  'goods': GoodsLocalizations.delegate,
  'group_buy': GroupBuyLocalizations.delegate,
  'home': HomeLocalizations.delegate,
  'marketing': MarketingLocalizations.delegate,
  'message': MessageLocalizations.delegate,
  'order': OrderLocalizations.delegate,
  'proxy_buy': ProxyBuyLocalizations.delegate,
  'search': SearchLocalizations.delegate,
  'user': UserLocalizations.delegate,
};

final Map<String, List<Locale>> _supportedLocales =
    <String, List<Locale>>{
  'app': AppLocalizations.supportedLocales,
  'auth': AuthLocalizations.supportedLocales,
  'catalog': CatalogLocalizations.supportedLocales,
  'discover': DiscoverLocalizations.supportedLocales,
  'goods': GoodsLocalizations.supportedLocales,
  'group_buy': GroupBuyLocalizations.supportedLocales,
  'home': HomeLocalizations.supportedLocales,
  'marketing': MarketingLocalizations.supportedLocales,
  'message': MessageLocalizations.supportedLocales,
  'order': OrderLocalizations.supportedLocales,
  'proxy_buy': ProxyBuyLocalizations.supportedLocales,
  'search': SearchLocalizations.supportedLocales,
  'user': UserLocalizations.supportedLocales,
};

/// 每套 l10n 在给定语种下的一条文案（用于断言"不是空串"）。
final Map<String, String Function(Object)> _probes =
    <String, String Function(Object)>{
  'app': (Object o) => (o as AppLocalizations).appTitle,
  'auth': (Object o) => (o as AuthLocalizations).authTitle,
  'catalog': (Object o) => (o as CatalogLocalizations).catalogProviders_74,
  'discover': (Object o) => (o as DiscoverLocalizations).discoverTitle,
  'goods': (Object o) => (o as GoodsLocalizations).goodsGoToOrder,
  'group_buy': (Object o) => (o as GroupBuyLocalizations).groupBuy_72,
  'home': (Object o) => (o as HomeLocalizations).homeTitle,
  'marketing': (Object o) => (o as MarketingLocalizations).couponPage_30,
  'message': (Object o) => (o as MessageLocalizations).messageTitle,
  'order': (Object o) => (o as OrderLocalizations).orderListTitle,
  'proxy_buy': (Object o) => (o as ProxyBuyLocalizations).proxyBuy_142,
  'search': (Object o) => (o as SearchLocalizations).searchProviders_22,
  'user': (Object o) => (o as UserLocalizations).userTitle,
};

void main() {
  group('各套 ARB 的语种集合一致', () {
    test('feature 级 supportedLocales 必须与应用级完全相同', () {
      final expected = AppLocalizations.supportedLocales;
      for (final entry in _supportedLocales.entries) {
        expect(
          entry.value,
          expected,
          reason: '${entry.key} 的语种与应用级不一致：'
              '某个语种缺翻译时运行时会回落到别的语言，很难发现',
        );
      }
    });
  });

  group('每套 l10n 在每个语种下都能加载且文案非空', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test('locale = $locale', () async {
        for (final entry in _delegates.entries) {
          final loaded = await entry.value.load(locale);
          final text = _probes[entry.key]!(loaded);
          expect(
            text.trim(),
            isNotEmpty,
            reason: '${entry.key} 在 $locale 下的文案为空',
          );
        }
      });
    }

    test('中英文案确实不同（防止复制粘贴漏翻）', () async {
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(zh.appTitle, isNot(equals(en.appTitle)));
    });
  });

  group('应用壳把全部 delegate 挂上了', () {
    test('appLocalizationsDelegates 含全部 13 套（按 identity 比，不靠字符串）', () {
      for (final entry in _delegates.entries) {
        expect(
          appLocalizationsDelegates.any(
            (LocalizationsDelegate<Object> d) => identical(d, entry.value),
          ),
          isTrue,
          reason: '${entry.key} 的 delegate 没被挂上',
        );
      }
    });

    testWidgets('用这份列表能取到每一套', (WidgetTester tester) async {
      late BuildContext context;
      // 刻意用 SizedBox 当页面：本测试只验证 delegate 集合，
      // 渲染真实页面会让它被首页/详情页的布局问题带崩（比如 RenderFlex 溢出），
      // 那些属于各 feature 自己的测试。
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 少挂一个 delegate 的症状是 `Localizations.of` 返回 null，
      // 页面里的 `XxxLocalizations.of(context)` 会直接崩。
      expect(Localizations.of<AppLocalizations>(context, AppLocalizations),
          isNotNull);
      expect(Localizations.of<AuthLocalizations>(context, AuthLocalizations),
          isNotNull);
      expect(
          Localizations.of<CatalogLocalizations>(
              context, CatalogLocalizations),
          isNotNull);
      expect(
          Localizations.of<DiscoverLocalizations>(
              context, DiscoverLocalizations),
          isNotNull);
      expect(Localizations.of<GoodsLocalizations>(context, GoodsLocalizations),
          isNotNull);
      expect(
          Localizations.of<GroupBuyLocalizations>(
              context, GroupBuyLocalizations),
          isNotNull);
      expect(Localizations.of<HomeLocalizations>(context, HomeLocalizations),
          isNotNull);
      expect(
          Localizations.of<MarketingLocalizations>(
              context, MarketingLocalizations),
          isNotNull);
      expect(
          Localizations.of<MessageLocalizations>(
              context, MessageLocalizations),
          isNotNull);
      expect(Localizations.of<OrderLocalizations>(context, OrderLocalizations),
          isNotNull);
      expect(
          Localizations.of<ProxyBuyLocalizations>(
              context, ProxyBuyLocalizations),
          isNotNull);
      expect(Localizations.of<SearchLocalizations>(context, SearchLocalizations),
          isNotNull);
      expect(Localizations.of<UserLocalizations>(context, UserLocalizations),
          isNotNull);
    });

    // 刻意**不**断言"某页面显示了某条文案"：
    // 页面内容属于各 feature 自己的测试职责，放在这里会把 l10n 接线测试
    // 和每个页面的改版绑死（改一次首页文案就红一片，久了就没人跑它）。
    // 这里只保证两件稳定的事：ARB 完整（上面的 group）、delegate 已挂载（本 group）。
  });
}
