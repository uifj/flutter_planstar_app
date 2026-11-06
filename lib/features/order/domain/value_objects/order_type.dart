import 'package:core/result.dart';

/// 下单类型（对应企划星的 `OrderType` 编译期常量）。
///
/// 原实现是 `@interface` + `public static final int`，`@Retention(SOURCE)`——
/// **运行时不存在**，服务端下发 `orderType=3` 客户端也不会拦（`wiki_zh/12` §5.4）。
/// 这里用 `enum` + [fromWire]，非法值直接变成 `Failure`。
enum OrderType {
  /// 普通票。
  ticket(1),

  /// 拼团。
  pinTuan(2),

  /// 抢票。
  grabTicket(5),

  /// Plus 会员充值（走 `v1/plusMember/charge/makeOrder`，与主单分叉）。
  plusMember(60),

  /// 加速包。
  speedPack(70);

  const OrderType(this.wireCode);

  final int wireCode;

  static Result<OrderType> fromWire(int code) {
    for (final type in OrderType.values) {
      if (type.wireCode == code) return Success<OrderType>(type);
    }
    return Fail<OrderType>(
      Failure(
        code: 'ORDER_TYPE_UNKNOWN',
        message: '未知下单类型：$code',
        type: FailureType.data,
      ),
    );
  }
}

/// 购买方式（对应 scheme 里的 `buyType`）。
///
/// 企划星侧 `buyType` 默认 `"1"`，`mIsProxyBuy = (buyType == 2)` 只有这一个标记位，
/// 但它影响协议弹窗文案和**代购页被裁掉的一整块能力**（`wiki_zh/modules/order-and-payment` §4）。
enum BuyType {
  /// 普通购买。
  normal(1),

  /// 代购（企划星代为下单）。
  proxy(2);

  const BuyType(this.wireCode);

  final int wireCode;

  static Result<BuyType> fromWire(int? code) {
    return switch (code) {
      null || 1 => const Success<BuyType>(BuyType.normal),
      2 => const Success<BuyType>(BuyType.proxy),
      _ => Fail<BuyType>(
        Failure(
          code: 'BUY_TYPE_UNKNOWN',
          message: '未知购买方式：$code',
          type: FailureType.data,
        ),
      ),
    };
  }
}
