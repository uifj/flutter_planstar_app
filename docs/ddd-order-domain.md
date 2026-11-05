# 订单领域层：DDD 战术模式落地

> 本文记录 `fp_order` 竖切里领域层的**为什么这么写**。代码在
> `lib/features/order/domain/` 与 `packages/core/domain/`，
> 业务依据来自 Android 原项目反编译 wiki（第 12 / 27 页与 `modules/order-and-payment.md`）。

## 0. 这次做了什么

用 `npx skills use "https://github.com/codewithmukesh/dotnet-claude-kit" --skill "ddd"`
拉到的技能是 **.NET 版 DDD 战术模式**（聚合、值对象、领域事件、强类型 id、
按聚合根建仓储、领域服务）。它给的每条规则都能直接映射到 Dart，
但**写法要换**——下面每张表都注明了"原技能怎么说 / Dart 怎么落"。

> 该技能的仓库里 `skills/ddd/` 只有 `SKILL.md` 一个文件，没有 supporting-files 目录，
> 所以不存在需要解析的相对路径。

## 1. 目录

```
packages/core/domain/            # core_domain：零 Flutter 依赖的领域原语
  lib/src/entity.dart            #   Entity<TId>（身份相等）
  lib/src/aggregate_root.dart    #   AggregateRoot<TId>（事件收集）
  lib/src/value_object.dart      #   ValueObject（属性相等 + 深比较）
  lib/src/domain_event.dart      #   DomainEvent
  lib/src/domain_event_bus.dart  #   进程内分发（按运行时类型精确匹配）
  lib/src/money.dart             #   Money（整数分）
  lib/src/quantity.dart          #   Quantity
  lib/src/id_generator.dart      #   IdGenerator 端口 + UUIDv7 形态实现

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
`domain` 只依赖 `core_domain` + `core_result`，**不认识 Flutter**。

## 2. 模式 → 代码

| 技能里的规则 | 这里的落点 | Dart 侧的关键差别 |
|---|---|---|
| 聚合定义一致性边界，根是唯一入口 | `TicketOrder` | 子实体 `OrderLine` 放在 `part` 文件里，改数量的方法 `_changeQuantity` 在 library 外不可见——Dart 没有 friend class，`part` 是标准替代 |
| 值对象优于裸类型 | `Money` / `Quantity` / `OrderNumber` / `IdCardNumber` / `DeliveryInfo` / `Visitor` | 构造函数即校验：非法状态**造不出来**（`IdCardNumber` 做 GB 11643 校验位验算） |
| 强类型 id | `extension type TicketOrderId(String)` 等 9 个 | 用 `extension type`（零运行时开销）而不是包装类；`ShowId` 传进 `orderId` 参数编译不过 |
| 领域事件解耦副作用 | `OrderPlaced` / `OrderPaid` / `OrderShipped` / `OrderCompleted` / `OrderCancelled` / `OrderRefunded` | 事件由聚合 `raise`，由控制器在**保存成功之后** `pull` 并 `dispatch`；`DomainEventBus` 按 `runtimeType` 精确匹配，不做 `is` 匹配 |
| 领域服务放跨聚合/多聚合逻辑 | `OrderPricingService`（纯函数）、`PurchaseLimitPolicy` | 金额公式抽成无状态服务，输入输出都是值对象——可以在纯 Dart 单测里跑 |
| 一个聚合根一个仓储 | `TicketOrderRepository`（端口）+ `InMemoryTicketOrderRepository`（适配器） | 仓储接口在 `domain/`，实现放 `data/`；`findById` 找不到返回 `Success(null)`，"查不到"与"查询失败"分开 |
| 避免贫血模型 | `submit()` / `markPaid()` / `cancel()` / `refund()` 都在聚合上 | 每个方法返回 `Result<void>`，校验与状态迁移在**一处** |

## 3. 修掉的三类真实缺陷

### 3.1 两套订单状态编码，前四个差 1

`wiki_zh/27` §11.1：`OrderStatus.INIT(1)` vs `OrderUtils.INIT = 0`，前四个状态全部差 1，
两个类还都是零引用，业务代码里全是裸 `status == 2`。

→ `OrderStatus.fromWire()` 是**唯一**入站映射表（`1` 与 `2` 都归到 `awaitingPayment`，
对用户是同一件事），未知编码返回 `Failure` 而不是兜底；状态迁移用白名单
`canTransitionTo()`，非法迁移返回 `ORDER_STATUS_ILLEGAL`。

### 3.2 `selectStatus` 三态靠 if/else 维持互斥

`wiki_zh/12` §3.5.4/§3.5.5：页面里 `selectStatus` 决定用活动还是券，
下单时**又写一遍** `if (i2 != 0) ... else if`，两处必须同步。

→ `sealed class DiscountSelection`，只有 `NoDiscount` / `CampaignSelection` /
`CouponSelection` 三个实现。"同时用活动和券"**构造不出来**，`promotionId` 只会有一个值。

### 3.3 金额散在 7 个 `double` 成员上

`wiki_zh/12` §3.5.4：`mTotalAmount` / `mPaymentAmount` / `mCampaignDiscount` /
`mCouponDiscount` / `mCostSpeedPackageAmount` / `mCostSpeedPackageBalance` / `mSelectStatus`，
`updatePrice()` 是唯一能算对它们的地方；礼品卡和加速包两处手写 `-` 没走 BigDecimal。

→ `Money` 全程整数分；`OrderQuote` 构造时自校验
`paymentAmount == payableBeforeTender − giftCardApplied + speedPackCash`；
聚合**任何内容变更都会让旧报价失效**（`_invalidateQuote`），`submit()` 前校验
`quote.isStaleFor(goodsTotal)`，从结构上消灭"页面显示一个价、请求发另一个价"。

另外两条顺带修掉的：

| 缺陷 | 原样 | 这里 |
|---|---|---|
| 交易协议默认勾选（`M5-01`，合规红旗） | `OrderConfirmViewModule` 构造时 `postValue(true)` | 默认 `false`，必须显式 `acceptAgreement()`，`submit()` 强制校验 |
| 实名证件只判空（`M5-07`，安全红旗） | `TextUtils.isEmpty` 后直接进请求 | `IdCardNumber` 校验位 + 出生日期；观演人按证件号去重、人数必须严格等于要求 |

## 4. 一次"加一张票"的调用链

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
submit() → order.submit(now)        // 校验协议/观演人/报价 → 迁移状态 → raise(OrderPlaced)
        → repository.save(order)    // 先保存
        → bus.dispatch(order.pullDomainEvents())   // 后发事件（反过来会出现"事件已发、事务回滚"）
```

## 5. 接真实接口时改哪里

只改三个 provider（`lib/features/order/application/order_providers.dart`）：

| Provider | 现在 | 换成 |
|---|---|---|
| `ticketOrderRepositoryProvider` | `InMemoryTicketOrderRepository` | 走 `core_network` 的 `ApiClient`，做 DTO ↔ 领域对象映射（`GET v1/unifiedOrder/confirm`、`POST v3/unifiedOrder/makeOrder`） |
| `orderNumberSequenceProvider` | 内存自增 | 服务端下发 / Redis `INCR` |
| `orderDraftSeedProvider` | 写死的演示数据 | `OrderConfirmInfo` 的防腐层转换结果 |

聚合、报价、事件、页面都不用动。

⚠ 唯一需要补的结构：真实仓储的 `save` 可能失败，而 `order.submit()` 已经把状态改了。
接网络实现时要把"submit + save"收进一个工作单元（失败回滚聚合），
`OrderConfirmController.submit()` 里已用注释标出这个位置。

## 6. 验证

```bash
flutter test test/features/order          # 48 个用例：领域 34 + 控制器 11 + 页面 3
flutter test packages/core/domain         # 22 个原语用例（Money / 事件 / 实体）
flutter analyze lib test packages/core/domain
```

金额公式的每条分支（券 / 活动封顶 / 活动不封顶 / 优惠超总额 / 礼品卡取小 /
加速包余额与现金 / 拆解自洽）都有对应用例，可以直接和 Android 版
`updatePrice()` 逐行对照。
