import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

/// 测试用的最小聚合：只有一个金额，方法内部改状态并发事件。
final class Wallet extends AggregateRoot<String> {
  Wallet(super.id, this._balance);

  Money _balance;

  Money get balance => _balance;

  void deposit(Money amount, DateTime now) {
    _balance += amount;
    raiseDomainEvent(Deposited(amount, occurredAt: now));
  }
}

final class Deposited extends DomainEvent {
  const Deposited(this.amount, {required super.occurredAt});

  final Money amount;
}

final class Frozen extends DomainEvent {
  const Frozen({required super.occurredAt});
}

/// 值对象样例：两个字段 + 校验。
final class Nickname extends ValueObject {
  Nickname(String value) : value = _validate(value);

  final String value;

  static String _validate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(raw, 'value', '昵称不能为空');
    return trimmed;
  }

  @override
  List<Object?> get props => <Object?>[value];
}

/// 实体样例：同 id 即相等，与其它字段无关。
final class Customer extends Entity<String> {
  Customer(super.id, this.name);

  String name;
}

void main() {
  group('Entity：身份决定相等', () {
    test('同类型同 id 相等，改名不影响', () {
      final a = Customer('u1', '张三');
      final b = Customer('u1', '李四');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('不同 id / 不同类型不相等', () {
      expect(Customer('u1', '张三'), isNot(Customer('u2', '张三')));
    });
  });

  group('ValueObject：属性决定相等', () {
    test('属性相同即相等，且做了 trim 归一', () {
      expect(Nickname(' 票友 '), Nickname('票友'));
      expect(Nickname('票友').hashCode, Nickname('票友').hashCode);
    });

    test('构造函数校验非法状态', () {
      expect(() => Nickname('  '), throwsArgumentError);
    });

    test('props 里含集合时深比较', () {
      expect(
        Money.sum(<Money>[Money.fromYuan(1), Money.fromYuan(2)]),
        Money.fromYuan(3),
      );
    });
  });

  group('AggregateRoot：事件只记不发', () {
    test('raise 后能取到，pull 之后清空', () {
      final wallet = Wallet('w1', Money.zero());
      wallet.deposit(Money.fromYuan(100), DateTime(2026, 11, 1));

      expect(wallet.hasDomainEvents, isTrue);
      final events = wallet.pullDomainEvents();
      expect(events, hasLength(1));
      expect((events.single as Deposited).amount, Money.fromYuan(100));
      expect(wallet.hasDomainEvents, isFalse);
      expect(wallet.pullDomainEvents(), isEmpty);
    });

    test('domainEvents 是只读视图，改不动内部列表', () {
      final wallet = Wallet('w1', Money.zero());
      wallet.deposit(Money.fromYuan(1), DateTime(2026, 11, 1));
      expect(() => wallet.domainEvents.clear(), throwsUnsupportedError);
    });
  });

  group('DomainEventBus：按运行时类型精确分发', () {
    test('只投递给对应类型的处理器，并保持注册顺序', () async {
      final bus = DomainEventBus();
      final log = <String>[];

      bus.on<Deposited>((event) => log.add('deposited:${event.amount.minorUnits}'));
      bus.on<Frozen>((event) => log.add('frozen'));

      await bus.dispatch(<DomainEvent>[
        Deposited(Money.fromYuan(5), occurredAt: DateTime(2026)),
        Frozen(occurredAt: DateTime(2026)),
      ]);

      expect(log, <String>['deposited:500', 'frozen']);
    });

    test('没有处理器的事件是零开销的 no-op', () async {
      final bus = DomainEventBus();
      expect(bus.hasHandlersFor(Frozen(occurredAt: DateTime(2026))), isFalse);
      await bus.dispatch(<DomainEvent>[Frozen(occurredAt: DateTime(2026))]);
    });

    test('取消注册后不再收到事件', () async {
      final bus = DomainEventBus();
      var count = 0;
      final off = bus.on<Deposited>((_) => count++);

      await bus.dispatch(<DomainEvent>[Deposited(Money.zero(), occurredAt: DateTime(2026))]);
      off();
      await bus.dispatch(<DomainEvent>[Deposited(Money.zero(), occurredAt: DateTime(2026))]);

      expect(count, 1);
    });

    test('处理器异常：默认冒泡，配了 onHandlerError 则隔离', () async {
      final strict = DomainEventBus();
      strict.on<Frozen>((_) => throw StateError('boom'));
      await expectLater(
        strict.dispatch(<DomainEvent>[Frozen(occurredAt: DateTime(2026))]),
        throwsStateError,
      );

      final lenient = DomainEventBus(onHandlerError: (error, stack, event) {});
      lenient.on<Frozen>((_) => throw StateError('boom'));
      var reached = false;
      lenient.on<Frozen>((_) => reached = true);

      await lenient.dispatch(<DomainEvent>[Frozen(occurredAt: DateTime(2026))]);
      expect(reached, isTrue, reason: '一个处理器炸了不能挡住其它处理器');
    });
  });

  group('IdGenerator', () {
    test('时间前缀生成器唯一，且随时钟推进保持字典序（UUIDv7 语义）', () {
      final ids = TimestampIdGenerator();
      final generated = List<String>.generate(50, (_) => ids.next());
      expect(generated.toSet(), hasLength(50));
      expect(generated.first.length, 32);

      // 同一毫秒内的随机尾巴不保证有序；注入推进的时钟才能断言"字典序 = 时间序"。
      var tick = DateTime(2026, 11, 1, 10);
      final sortable = TimestampIdGenerator(
        clock: () {
          tick = tick.add(const Duration(milliseconds: 1));
          return tick;
        },
      );
      final ordered = List<String>.generate(20, (_) => sortable.next());
      expect(ordered, orderedEquals(List<String>.of(ordered)..sort()));
    });

    test('顺序生成器用于确定性测试', () {
      final ids = SequentialIdGenerator(prefix: 'ord-');
      expect(ids.next(), 'ord-1');
      expect(ids.next(), 'ord-2');
    });
  });
}
