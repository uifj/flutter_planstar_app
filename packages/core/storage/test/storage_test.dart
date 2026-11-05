import 'package:core_storage/core_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// 一个可序列化的小对象，用于列表存储测试。
class _RecentSearch {
  const _RecentSearch(this.keyword, this.at);

  final String keyword;
  final int at;

  static _RecentSearch fromJson(Map<String, Object?> json) => _RecentSearch(
        json['keyword']! as String,
        json['at']! as int,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'keyword': keyword,
        'at': at,
      };
}

void main() {
  group('MemoryKeyValueStore', () {
    test('读写删清', () async {
      final store = MemoryKeyValueStore();
      expect(await store.read('a'), isNull);

      await store.write('a', '1');
      expect(await store.read('a'), '1');
      expect(await store.keys(), <String>{'a'});

      await store.delete('a');
      expect(await store.read('a'), isNull);

      await store.write('b', '2');
      await store.clear();
      expect(await store.keys(), isEmpty);
    });
  });

  group('类型化扩展', () {
    test('int 往返', () async {
      final store = MemoryKeyValueStore();
      await store.writeInt('n', 42);
      expect(await store.readInt('n'), 42);
    });

    test('int 解析失败返回 null（不抛）', () async {
      final store = MemoryKeyValueStore(<String, String>{'n': 'abc'});
      expect(await store.readInt('n'), isNull);
    });

    test('bool 往返，非法值返回 null', () async {
      final store = MemoryKeyValueStore();
      await store.writeBool('f', true);
      expect(await store.readBool('f'), isTrue);

      await store.write('bad', 'yes');
      expect(await store.readBool('bad'), isNull);
    });

    test('JSON 往返', () async {
      final store = MemoryKeyValueStore();
      await store.writeJson('j', <String, Object?>{'a': 1, 'b': <int>[1, 2]});
      final back = await store.readJson('j');
      expect(back, <String, Object?>{'a': 1, 'b': <Object?>[1, 2]});
    });

    test('JSON 损坏返回 null（当作未命中，而不是崩）', () async {
      final store = MemoryKeyValueStore(<String, String>{'j': '{not json'});
      expect(await store.readJson('j'), isNull);
    });

    test('JSON 是数组而非对象时返回 null', () async {
      final store = MemoryKeyValueStore(<String, String>{'j': '[1,2]'});
      expect(await store.readJson('j'), isNull);
    });
  });

  group('ScopedKeyValueStore 按用户隔离', () {
    test('不同用户互不可见', () async {
      final inner = MemoryKeyValueStore();
      final alice = ScopedKeyValueStore(inner, 'alice');
      final bob = ScopedKeyValueStore(inner, 'bob');

      await alice.write('history', 'a');
      await bob.write('history', 'b');

      expect(await alice.read('history'), 'a');
      expect(await bob.read('history'), 'b');
      // 底层真的存了两个不同的键。
      expect((await inner.keys()).length, 2);
    });

    test('clear 只清自己的', () async {
      final inner = MemoryKeyValueStore();
      final alice = ScopedKeyValueStore(inner, 'alice');
      final bob = ScopedKeyValueStore(inner, 'bob');
      await alice.write('x', '1');
      await bob.write('x', '2');

      await alice.clear();
      expect(await alice.read('x'), isNull);
      expect(await bob.read('x'), '2', reason: '不能误删别的用户数据');
    });

    test('keys 返回去掉前缀后的键', () async {
      final inner = MemoryKeyValueStore();
      final alice = ScopedKeyValueStore(inner, 'alice');
      await alice.write('x', '1');
      await alice.write('y', '2');
      expect(await alice.keys(), <String>{'x', 'y'});
    });
  });

  group('AppStore', () {
    test('onLogout 默认清安全存储、保留偏好', () async {
      final prefs = MemoryKeyValueStore();
      final secure = MemorySecureStore();
      final store = AppStore(preferences: prefs, secure: secure);

      await prefs.write('fontSize', '16');
      await secure.write('token', 'secret');

      await store.onLogout();

      expect(await secure.read('token'), isNull, reason: 'token 必须清');
      expect(await prefs.read('fontSize'), '16', reason: '设备级偏好应保留');
    });

    test('onLogout(keepPreferences: false) 两者都清', () async {
      final prefs = MemoryKeyValueStore();
      final secure = MemorySecureStore();
      final store = AppStore(preferences: prefs, secure: secure);
      await prefs.write('a', '1');
      await secure.write('token', 't');

      await store.onLogout(keepPreferences: false);

      expect(await prefs.read('a'), isNull);
      expect(await secure.read('token'), isNull);
    });

    test('forUser 返回隔离视图', () async {
      final prefs = MemoryKeyValueStore();
      final store = AppStore(
        preferences: prefs,
        secure: MemorySecureStore(),
      );
      final u1 = store.forUser('u1');
      await u1.write('k', 'v');
      expect(await prefs.read('u1:k'), 'v');
    });
  });

  group('JsonListStore', () {
    JsonListStore<_RecentSearch> build(
      KeyValueStore store, {
      int? maxItems,
    }) =>
        JsonListStore<_RecentSearch>(
          store: store,
          key: 'recent',
          fromJson: _RecentSearch.fromJson,
          toJson: (_RecentSearch v) => v.toJson(),
          maxItems: maxItems,
        );

    test('往返', () async {
      final store = build(MemoryKeyValueStore());
      await store.writeAll(<_RecentSearch>[
        const _RecentSearch('周杰伦', 1),
        const _RecentSearch('五月天', 2),
      ]);
      final back = await store.readAll();
      expect(back.map((_RecentSearch e) => e.keyword), <String>['周杰伦', '五月天']);
      expect(back.first.at, 1);
    });

    test('append 追加到末尾', () async {
      final store = build(MemoryKeyValueStore());
      await store.append(const _RecentSearch('a', 1));
      await store.append(const _RecentSearch('b', 2));
      final back = await store.readAll();
      expect(back.map((_RecentSearch e) => e.keyword), <String>['a', 'b']);
    });

    test('maxItems 裁剪时保留最新的', () async {
      final store = build(MemoryKeyValueStore(), maxItems: 2);
      await store.append(const _RecentSearch('a', 1));
      await store.append(const _RecentSearch('b', 2));
      await store.append(const _RecentSearch('c', 3));
      final back = await store.readAll();
      expect(back.map((_RecentSearch e) => e.keyword), <String>['b', 'c']);
    });

    test('坏 JSON 返回空列表', () async {
      final store = build(MemoryKeyValueStore(<String, String>{'recent': 'xx'}));
      expect(await store.readAll(), isEmpty);
    });

    test('单条坏数据被跳过，其余保留', () async {
      final inner = MemoryKeyValueStore(<String, String>{
        'recent': '[{"keyword":"ok","at":1},{"keyword":123},{"nope":1}]',
      });
      final store = build(inner);
      final back = await store.readAll();
      expect(back.length, 1);
      expect(back.single.keyword, 'ok');
    });

    test('clear 删除键', () async {
      final inner = MemoryKeyValueStore();
      final store = build(inner);
      await store.append(const _RecentSearch('a', 1));
      await store.clear();
      expect(await inner.read('recent'), isNull);
    });
  });
}
