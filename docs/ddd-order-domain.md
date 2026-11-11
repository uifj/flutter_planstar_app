# 订单领域层：DDD 战术模式落地

> 适用版本：planstar Flutter 1.0.1 · 最后核对：2026-11-11 · 维护：客户端组

> 本文记录订单竖切里领域层的**为什么这么写**。代码在
> `lib/features/order/domain/` 与 `packages/infras/core/lib/src/domain/`，
> 产品口径见 `planstar_kratos_server/docs/product/POSITIONING.md`。

## 0. 这套模式的来源

领域层用的是 **DDD 战术模式**（聚合、值对象、领域事件、强类型 id、
按聚合根建仓储、领域服务）。这些规则本身与语言无关，
但**写法要换**——下面每张表都注明了"模式怎么说 / Dart 怎么落"。

## 1. 目录

```
packages/infras/core/lib/src/domain/   # core 的 domain 子库：零 Flutter 依赖的领域原语
  entity.dart                    #   Entity<TId>（身份相等）
  aggregate_root.dart            #   AggregateRoot<TId>（事件收集）
  value_object.dart              #   ValueObject（属性相等 + 深比较）
  domain_event.dart              #   DomainEvent
  domain_event_bus.dart          #   进程内分发（按运行时类型精确匹配）
  money.dart                     #   Money（整数分）
  quantity.dart                  #   Quantity
  id_generator.dart              #   IdGenerator 端口 + UUIDv7 形态实现

lib/features/order/
  domain/                        # 领域层：不 import Flutter，不 import Dio
    aggregates/ticket_order.dart #   聚合根 + part order_line.dart
    value_objects/               #   ids / order_number / order_status / order_type
                                 #   discount / delivery / visitor / speed_pack / payment_channel
    services/order_quote.dart    #   报价值对象（自校验）
    services/order_pricing_service.dart   # 领域服务：金额公式
    policies/purchase_limit_policy.dart   # 限购策略
    events/                      #   order_placed / order_paid / order_lifecycle_events
    repositories/                #   端口：TicketOrderRepository / OrderNumberSequence
    domain.dart                  #   对外唯一出口
  data/                          # 适配器：内存仓储、内存订单号序列
  application/                   # Riverpod 控制器 + 领域事件订阅 + 演示数据
  order_confirm_page.dart        # 纯展示
```

依赖方向：`presentation → application → domain ← data`。
`domain` 只依赖 `package:core/domain.dart` + `package:core/result.dart`，**不认识 Flutter**。

## 2. 模式 → 代码

| 模式规则 | 这里的落点 | Dart 侧的关键差别 |
|---|---|---|
| 聚合定义一致性边界，根是唯一入口 | `TicketOrder` | 子实体 `OrderLine` 放在 `part` 文件里，改数量的方法 `_changeQuantity` 在 library 外不可见——Dart 没有 friend class，`part` 是标准替代 |
| 值对象优于裸类型 | `Money` / `Quantity` / `OrderNumber` / `IdCardNumber` / `DeliveryInfo` / `Visitor` | 构造函数即校验：非法状态**造不出来**（`IdCardNumber` 做 GB 11643 校验位验算） |
| 强类型 id | `extension type TicketOrderId(String)` 等 9 个 | 用 `extension type`（零运行时开销）而不是包装类；`ShowId` 传进 `orderId` 参数编译不过 |
| 领域事件解耦副作用 | `OrderPlaced` / `OrderPaid` / `OrderShipped` / `OrderCompleted` / `OrderCancelled` / `OrderRefunded` | 事件由聚合 `raise`，由控制器在**保存成功之后** `pull` 并 `dispatch`；`DomainEventBus` 按 `runtimeType` 精确匹配，不做 `is` 匹配 |
| 领域服务放跨聚合/多聚合逻辑 | `OrderPricingService`（纯函数）、`PurchaseLimitPolicy` | 金额公式抽成无状态服务，输入输出都是值对象——可以在纯 Dart 单测里跑 |
| 一个聚合根一个仓储 | `TicketOrderRepository`（端口）+ `InMemoryTicketOrderRepository`（适配器） | 仓储接口在 `domain/`，实现放 `data/`；`findById` 找不到返回 `Success(null)`，"查不到"与"查询失败"分开 |
| 避免贫血模型 | `submit()` / `markPaid()` / `cancel()` / `refund()` 都在聚合上 | 每个方法返回 `Result<void>`，校验与状态迁移在**一处** |

## 3. 这套设计防住的三类真实缺陷

以下三类都是订单域里反复出现、且**要到用户对账时才暴露**的缺陷。
这里不靠"小心一点"防，靠结构防。

### 3.1 多套状态编码并存，页面各自裸比数字

同一份订单状态在不同层用不同起点编号（一套从 1 起、一套从 0 起），
页面里于是散落着裸 `status == 2`。任何一处漏改都会把"待支付"读成别的状态。

→ `OrderStatus.fromWire()` 是**唯一**入站映射表（`1` 与 `2` 都归到 `awaitingPayment`，
对用户是同一件事），未知编码返回 `Failure` 而不是兜底；状态迁移用白名单
`canTransitionTo()`，非法迁移返回 `ORDER_STATUS_ILLEGAL`。

### 3.2 互斥选项靠 if/else 维持，且要写两遍

"用活动还是用券"这种互斥选择，如果在页面里用一个 `selectStatus` 变量表示，
下单时就得**再写一遍**同样的 `if / else if`，两处必须永远同步。

→ `sealed class DiscountSelection`，只有 `NoDiscount` / `CampaignSelection` /
`CouponSelection` 三个实现。"同时用活动和券"**构造不出来**，`promotionId` 只会有一个值。

### 3.3 金额散在多个 `double` 成员上，只有一个函数能算对

总额 / 应付 / 活动优惠 / 券优惠 / 加速包现金 / 加速包余额各自是一个可变字段，
只有某个 `updatePrice()` 知道它们的关系；别处手写加减就会漂移，
浮点还会让"减完剩 0.01"这种错悄悄出现。

→ `Money` 全程整数分；`OrderQuote` 构造时自校验
`paymentAmount == payableBeforeTender − giftCardApplied + speedPackCash`；
聚合**任何内容变更都会让旧报价失效**（`_invalidateQuote`），`submit()` 前校验
`quote.isStaleFor(goodsTotal)`，从结构上消灭"页面显示一个价、请求发另一个价"。

另外两条同源的合规 / 安全红旗：

| 缺陷 | 放任的写法 | 这里 |
|---|---|---|
| 交易协议默认勾选（合规红旗） | 页面 ViewModel 构造时就把同意置为 `true` | 默认 `false`，必须显式 `acceptAgreement()`，`submit()` 强制校验 |
| 实名证件只判空（安全红旗） | 判非空后直接进请求 | `IdCardNumber` 做 GB 11643 校验位 + 出生日期验算；支持者按证件号去重、人数必须严格等于要求 |

## 4. 一次"加一份支持"的调用链

```
_TierRow.onIncrease
  → OrderConfirmController.increase(tierId)          // 应用层
    → TicketOrder.addLine(OrderLine)                 // 聚合：限购 + 合并 + 作废旧报价
    → OrderPricingService.quote(...)                 // 领域服务：算出 OrderQuote
    → TicketOrder.attachQuote(quote)                 // 聚合：报价快照
    → state = OrderConfirmState(order, quote)        // 页面重绘
```

提交时：

```
submit() → order.submit(now)        // 校验协议/支持者/报价 → 迁移状态 → raise(OrderPlaced)
        → repository.save(order)    // 先保存
        → bus.dispatch(order.pullDomainEvents())   // 后发事件（反过来会出现"事件已发、事务回滚"）
```

## 5. 真实接口接到哪一步了

装配都在 `lib/features/order/application/order_providers.dart`，
按 `dataSourcePolicyProvider` 切换演示 / 真实：

| Provider | 演示模式 | 真实模式 |
|---|---|---|
| `ticketOrderRepositoryProvider` | `InMemoryTicketOrderRepository`，用 `buildDemoOrderHistory` 驱动真实聚合跑出订单 | `RemoteTicketOrderRepository`（`PlanstarOrderApi` + `LocalOrderStore`），走 `GET v1/unifiedOrder/confirm`、`POST v3/unifiedOrder/makeOrder` |
| `orderDraftSeedProvider` | 写死的演示数据 | 从已加载的企划详情映射回报档位 / 线下回报场次 |
| `orderNumberSequenceProvider` | `InMemoryOrderNumberSequence` | **仍是内存自增**——订单号由服务端下发，本地序列只用于演示 |

聚合、报价、事件、页面都不随数据源变化。

**工作单元已经落地**：真实仓储的 `save` 会失败，而 `order.submit()` 已经改过状态。
`OrderConfirmController.submit()` 在远端建单失败与本地保存失败两处都调用
`order.reopenForRetry()` 把聚合退回草稿态并丢弃未分发的 `OrderPlaced`，
用户可以在当前页直接重试；事件仍然是**先保存、后分发**。

## 6. 验证

```bash
flutter analyze lib test packages/infras/core/lib   # 与 CI 同范围
flutter test test/features/order                    # 订单竖切：领域 / 控制器 / 页面 / 持久化 / 支付 / 退款
flutter test                                        # 客户端全量
```

`packages/infras/core` 的原语用例（`Money` / 领域事件 / 实体 / 缓存 / 网络）不在
根 `flutter test` 的范围内，需要单独进包跑：

```bash
cd packages/infras/core && flutter test
```

金额公式的每条分支（券 / 活动封顶 / 活动不封顶 / 优惠超总额 / 礼品卡取小 /
加速包余额与现金 / 拆解自洽）都有对应用例，改公式会直接挂测试，
而不是等用户对账时发现价格不对。
