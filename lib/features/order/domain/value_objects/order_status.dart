import 'package:core/result.dart';

/// 订单状态机。
///
/// ## 为什么不用服务端的裸 `int`
///
/// 企划星 Android 侧有两套编码，**前四个状态差 1**（`wiki_zh/27` §11.1）：
///
/// | 状态 | `OrderStatus.code` | `OrderUtils` | 一致 |
/// |---|---|---|---|
/// | INIT | 1 | 0 | ❌ |
/// | PAYING | 2 | 1 | ❌ |
/// | WAITING_FOR_TICKETS | 3 | 2 | ❌ |
/// | GETTING_TICKETS | 4 | 3 | ❌ |
/// | FINISHED | 5 | 5 | ✅ |
/// | CANCELED | 6 | 6 | ✅ |
/// | REFUNDED | 7 | 7 | ✅ |
///
/// 两个类都是零引用，业务代码里全是裸字面量 `status == 2`——"两个错误答案
/// 逼出一个更差答案"。这里的对策是：**只有一个入站映射表**（[fromWire]），
/// 未知编码返回失败而不是静默兜底；状态之间只允许显式声明的迁移。
enum OrderStatus {
  /// 客户端草稿：还没提交到服务端，**没有 wire code**。
  draft(wireCode: null, unpaid: true),

  /// 待支付。服务端的 `INIT(1)` 与 `PAYING(2)` 都归到这里——
  /// 两者对用户是同一件事（还没付钱），差别只在服务端内部流程。
  awaitingPayment(wireCode: 2, unpaid: true),

  /// 待发货（纸质票已支付、等待出票寄出）。
  awaitingTickets(wireCode: 3, unpaid: false),

  /// 待收货（已寄出 / 电子票待确认）。
  ticketsInTransit(wireCode: 4, unpaid: false),

  /// 已完成。
  completed(wireCode: 5, unpaid: false),

  /// 已关闭。
  cancelled(wireCode: 6, unpaid: false),

  /// 已退款。
  refunded(wireCode: 7, unpaid: false);

  const OrderStatus({required this.wireCode, required this.unpaid});

  /// 出站/入站用的服务端编码。`draft` 为 `null`。
  final int? wireCode;

  /// 是否属于"还没付钱"。
  final bool unpaid;

  /// 是否终态（不可再迁移）。
  bool get isTerminal => this == cancelled || this == refunded;

  /// 是否已支付成功过（用于判断能否退款）。
  bool get isPaid =>
      this == awaitingTickets || this == ticketsInTransit || this == completed;

  /// 服务端编码 → 状态。
  ///
  /// ⚠ `1`（INIT，订单创建成功）映射到 [awaitingPayment]：它是"已创建未支付"，
  /// 与 `PAYING(2)` 对用户无差别。这条映射写在**唯一一个地方**，
  /// 而不是像原 App 那样在 12 个 Activity 里各写一次 `== 2`。
  static Result<OrderStatus> fromWire(int code) {
    return switch (code) {
      1 || 2 => const Success<OrderStatus>(OrderStatus.awaitingPayment),
      3 => const Success<OrderStatus>(OrderStatus.awaitingTickets),
      4 => const Success<OrderStatus>(OrderStatus.ticketsInTransit),
      5 => const Success<OrderStatus>(OrderStatus.completed),
      6 => const Success<OrderStatus>(OrderStatus.cancelled),
      7 => const Success<OrderStatus>(OrderStatus.refunded),
      _ => Fail<OrderStatus>(
        Failure(
          code: 'ORDER_STATUS_UNKNOWN',
          message: '未知订单状态编码：$code',
          type: FailureType.data,
        ),
      ),
    };
  }

  /// 是否允许迁移到 [next]。
  ///
  /// 用白名单而不是"黑名单 + 一堆 if"：新增状态时**必须**在这里表态，
  /// 否则任何迁移都会被拒——编译期不报错，但测试会立刻挂。
  bool canTransitionTo(OrderStatus next) => switch (this) {
    OrderStatus.draft =>
      next == OrderStatus.awaitingPayment || next == OrderStatus.cancelled,
    OrderStatus.awaitingPayment =>
      next == OrderStatus.awaitingTickets || next == OrderStatus.cancelled,
    OrderStatus.awaitingTickets =>
      next == OrderStatus.ticketsInTransit ||
          next == OrderStatus.completed ||
          next == OrderStatus.refunded,
    OrderStatus.ticketsInTransit =>
      next == OrderStatus.completed || next == OrderStatus.refunded,
    OrderStatus.completed => next == OrderStatus.refunded,
    OrderStatus.cancelled => false,
    OrderStatus.refunded => false,
  };
}

/// 订单关闭原因。
///
/// 领域层只保留语义，展示文案由 UI 层按 l10n 解析。
enum OrderCancelReason {
  /// 用户主动取消。
  userCancelled,

  /// 支付超时自动关闭。
  timeout,
}
