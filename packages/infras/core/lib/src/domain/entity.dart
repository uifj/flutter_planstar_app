/// `Entity`：**有身份**的对象。两个实体相等，当且仅当类型相同且 id 相同。
///
/// 与 [ValueObject] 的分界线：`Address('南京西路 1 号')` 是值对象（换个街道就不是
/// 同一个地址了），`Order#42` 是实体（改了金额、改了状态，它还是 42 号订单）。
library;

import 'value_object.dart';

/// 有身份的领域对象。
///
/// [TId] 建议用强类型 ID（`extension type TicketOrderId(String value)`），
/// 这样 `ShowId` 与 `TicketOrderId` 在编译期就不能互换——企划星 Android 侧
/// 94 个模型都用裸 `int` 存 id（`wiki_zh/27` §10），把 `activityId` 传给
/// `orderId` 参数是编译得过的。
abstract class Entity<TId> {
  const Entity(this.id);

  /// 实体身份。创建后不可变。
  final TId id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return (other as Entity<TId>).id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() => '$runtimeType($id)';
}

/// 给 `List<Entity>` 之类的集合用的相等判断工具（例如值对象里含实体列表）。
bool entityListEquals(List<Entity<Object?>> a, List<Entity<Object?>> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
