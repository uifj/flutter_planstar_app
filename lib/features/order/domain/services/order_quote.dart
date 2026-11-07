import 'package:core/domain.dart';

/// 费用明细的项目类型。
enum QuoteLineKind {
  goodsTotal,
  postage,
  splitFee,
  discount,
  giftCard,
  speedPack,
}

/// 费用明细的一行（对应企划星 `ExpenseDetailsView` 的弹窗）。
final class QuoteLine extends ValueObject {
  const QuoteLine({
    required this.kind,
    required this.amount,
    this.isDeduction = false,
  });

  /// 项目类型（展示文案由 UI 层按 l10n 解析）。
  final QuoteLineKind kind;

  /// 金额（抵扣项为负）。
  final Money amount;

  /// 是否抵扣项（UI 用红色/负号渲染）。
  final bool isDeduction;

  @override
  List<Object?> get props => <Object?>[kind, amount, isDeduction];
}

/// 一次报价：**下单时发给服务端的两个金额 + 拆解**。
///
/// ## 为什么要有这个值对象
///
/// 企划星侧把金额拆在 Activity 的成员变量里：`mTotalAmount`（原价）、
/// `mPaymentAmount`（实付）、`mCampaignDiscount`、`mCouponDiscount`、
/// `mCostSpeedPackageAmount`、`mCostSpeedPackageBalance`、`mSelectStatus`……
/// 7 个 `double` 互相依赖，`updatePrice()` 是唯一能算对它们的地方，
/// 任何一处漏调就出现"页面显示 A、请求发 B"（`wiki_zh/12` §3.5.4 坑 2/3）。
///
/// [OrderQuote] 把这些收成一个**不可变、自洽**的对象：构造时校验
/// `paymentAmount == payableBeforeTender - giftCardApplied + speedPackCash`，
/// 一旦有人改坏了公式，测试立刻挂，而不是等用户发现价格不对。
///
/// 两个金额都必须发给服务端（服务端交叉校验防前端改价）：
/// - [totalAmount]：订单原价（商品 + 运费 + 拆单费）
/// - [paymentAmount]：用户实付
final class OrderQuote extends ValueObject {
  OrderQuote({
    required this.goodsTotal,
    required this.postage,
    required this.splitFee,
    required this.discountApplied,
    required this.totalAmount,
    required this.giftCardApplied,
    required this.speedPackCash,
    required this.speedPackBalance,
    required this.paymentAmount,
  }) {
    _assertNotNegative(goodsTotal, 'goodsTotal');
    _assertNotNegative(postage, 'postage');
    _assertNotNegative(splitFee, 'splitFee');
    _assertNotNegative(discountApplied, 'discountApplied');
    _assertNotNegative(giftCardApplied, 'giftCardApplied');
    _assertNotNegative(speedPackCash, 'speedPackCash');
    _assertNotNegative(speedPackBalance, 'speedPackBalance');
    _assertNotNegative(paymentAmount, 'paymentAmount');

    if (totalAmount != goodsTotal + postage + splitFee) {
      throw ArgumentError('totalAmount 必须等于 商品总额 + 运费 + 拆单费');
    }
    if (paymentAmount !=
        payableBeforeTender - giftCardApplied + speedPackCash) {
      throw ArgumentError('paymentAmount 与拆解项不自洽');
    }
  }

  /// 商品总额（票档小计之和）。
  final Money goodsTotal;

  /// 运费。
  final Money postage;

  /// 拆单费。
  final Money splitFee;

  /// 优惠抵扣额（营销活动或券，**只有一个**）。
  final Money discountApplied;

  /// 订单原价 = 商品总额 + 运费 + 拆单费。
  final Money totalAmount;

  /// 礼品卡实际抵扣额。
  final Money giftCardApplied;

  /// 加速包的现金部分（计入应付）。
  final Money speedPackCash;

  /// 加速包的余额部分（已用余额抵扣，不计入应付）。
  final Money speedPackBalance;

  /// 用户实付。
  final Money paymentAmount;

  /// 抵扣优惠后、礼品卡之前的应付。
  Money get payableBeforeTender =>
      (totalAmount - discountApplied).atLeastZero();

  /// 是否需要在线支付（实付 0 元时可以直接成单）。
  bool get requiresPayment => paymentAmount.isPositive;

  /// 报价是否对当前商品总额失效。
  ///
  /// 聚合在 `submit()` 前必须检查：用户改了数量但没重算报价时，
  /// 发出去的会是旧价格——这正是企划星"两个金额分别设置"最容易出的错。
  bool isStaleFor(Money currentGoodsTotal) => currentGoodsTotal != goodsTotal;

  /// 费用明细（按企划星弹窗的顺序）。
  List<QuoteLine> get breakdown => <QuoteLine>[
    QuoteLine(kind: QuoteLineKind.goodsTotal, amount: goodsTotal),
    if (!postage.isZero)
      QuoteLine(kind: QuoteLineKind.postage, amount: postage),
    if (!splitFee.isZero)
      QuoteLine(kind: QuoteLineKind.splitFee, amount: splitFee),
    if (!discountApplied.isZero)
      QuoteLine(
        kind: QuoteLineKind.discount,
        amount: discountApplied.negated(),
        isDeduction: true,
      ),
    if (!giftCardApplied.isZero)
      QuoteLine(
        kind: QuoteLineKind.giftCard,
        amount: giftCardApplied.negated(),
        isDeduction: true,
      ),
    if (!speedPackCash.isZero)
      QuoteLine(kind: QuoteLineKind.speedPack, amount: speedPackCash),
  ];

  @override
  List<Object?> get props => <Object?>[
    goodsTotal,
    postage,
    splitFee,
    discountApplied,
    totalAmount,
    giftCardApplied,
    speedPackCash,
    speedPackBalance,
    paymentAmount,
  ];

  static void _assertNotNegative(Money money, String name) {
    if (money.isNegative) {
      throw ArgumentError('$name 不能为负：${money.format()}');
    }
  }
}

/// 服务端确认报价（`POST /v1/unifiedOrder/confirm`）。
///
/// 建单金额以服务端返回为准；本地 [OrderQuote] 只用于预演与拆解展示。
final class OrderServerQuote {
  const OrderServerQuote({
    this.quoteId,
    required this.totalAmount,
    required this.paymentAmount,
    this.expiresAt,
  });

  final String? quoteId;
  final Money totalAmount;
  final Money paymentAmount;
  final DateTime? expiresAt;

  /// 把服务端报价转成自洽的 [OrderQuote]，供确认页展示。
  ///
  /// 服务端只承诺原价/实付两个数，这里把差额记成优惠，保证
  /// `total = goods + postage + split`、`payment = payable - discount`。
  OrderQuote toDisplayQuote() {
    final total = totalAmount.minorUnits;
    final rawPayment = paymentAmount.minorUnits;
    final payment = rawPayment < 0
        ? 0
        : (rawPayment > total ? total : rawPayment);
    return OrderQuote(
      goodsTotal: totalAmount,
      postage: Money.zero(),
      splitFee: Money.zero(),
      discountApplied: Money.fromMinorUnits(total - payment),
      totalAmount: totalAmount,
      giftCardApplied: Money.zero(),
      speedPackCash: Money.zero(),
      speedPackBalance: Money.zero(),
      paymentAmount: Money.fromMinorUnits(payment),
    );
  }

  /// 解析服务端报价；缺少金额字段时返回 `null`（调用方回退本地报价）。
  static OrderServerQuote? tryParse(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['quote'] ?? json['orderAmount'];
    final source = nested is Map<String, dynamic> ? nested : json;
    final totalRaw =
        source['totalAmount'] ?? source['total'] ?? source['orderAmount'];
    if (totalRaw is! num) return null;

    final payRaw =
        source['paymentAmount'] ??
        source['payAmount'] ??
        source['amount'] ??
        totalRaw;
    final quoteId =
        source['quoteId']?.toString() ?? source['quoteNo']?.toString();
    final expiresRaw =
        source['expiresAt'] ?? source['expireAt'] ?? source['expireTime'];

    return OrderServerQuote(
      quoteId: quoteId == null || quoteId.isEmpty ? null : quoteId,
      // 后端金额统一为分；用 `fromMinorUnits` 避免 double 误差。
      totalAmount: Money.fromMinorUnits(totalRaw.toInt()),
      paymentAmount: Money.fromMinorUnits(
        payRaw is num ? payRaw.toInt() : totalRaw.toInt(),
      ),
      expiresAt: _parseTime(expiresRaw),
    );
  }

  static DateTime? _parseTime(Object? raw) {
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }
    return DateTime.tryParse(raw?.toString() ?? '');
  }
}
