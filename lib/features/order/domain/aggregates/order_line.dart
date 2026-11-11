part of 'ticket_order.dart';

/// 订单行（子实体）：一个回报档位 + 数量 + 单价。
///
/// 为什么是**实体**而不是值对象：同一张支持单里"档位 A 2 份"和"档位 B 1 份"
/// 是两个不同的东西，各有各的身份（回报档位 id），而不是"两个属性相同的值"。
///
/// 为什么它的修改方法都是 `_` 开头：子实体只能由聚合根改。
/// 外部拿到 `order.lines` 后能读不能写——`_changeQuantity` 在 library 外不可见。
final class OrderLine extends Entity<TicketTierId> {
  OrderLine({
    required TicketTierId id,
    required this.tierName,
    required this.unitPrice,
    required Quantity quantity,
  }) : _quantity = quantity,
       super(id) {
    if (tierName.trim().isEmpty) {
      throw ArgumentError.value(tierName, 'tierName', '回报档位名不能为空');
    }
    if (unitPrice.isNegative) {
      throw ArgumentError.value(unitPrice, 'unitPrice', '单价不能为负');
    }
  }

  /// 回报档位名（展示用，取自企划详情的档位标题）。
  final String tierName;

  /// 单价。
  final Money unitPrice;

  Quantity _quantity;

  /// 数量。
  Quantity get quantity => _quantity;

  /// 小计 = 单价 × 数量。
  Money get subtotal => unitPrice * _quantity.value;

  /// 只有聚合根能改数量。
  void _changeQuantity(Quantity next) => _quantity = next;

  @override
  String toString() => '$tierName × ${_quantity.value} = ${subtotal.format()}';
}
