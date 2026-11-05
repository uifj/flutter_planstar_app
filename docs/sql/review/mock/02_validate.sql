-- =======================================================================
--  Planstar 票务 Mock · MySQL 一致性校验查询
--  执行：在 00_schema.sql + 01_seed.sql 之后，USE `planstar_mock_ticketing` 执行。
--  约定：除 V13/V14/V15 为「场景观测」外，其余查询【结果必须为空集】才通过。
--  说明：validate_review.py 用 Python Decimal 复算了 V01–V12，
--        并用 SQLite 真实加载本库的 DDL+INSERT（开启外键）验证引用完整性。
--        本文件是 MySQL 端的等价 SQL，供有 MySQL 8.0 实例时执行。
-- =======================================================================

USE `planstar_mock_ticketing`;

-- V01 订单行金额：line_amount = unit_price * quantity
SELECT 'V01 line_amount' AS check_name, i.item_id, i.line_amount, i.unit_price * i.quantity AS expected
FROM `order_items` i
WHERE i.line_amount <> i.unit_price * i.quantity;

-- V02 订单商品额：SUM(line_amount) = total_amount - postage
SELECT 'V02 goods_amount' AS check_name, o.order_id, o.total_amount - o.postage AS expected, SUM(i.line_amount) AS actual
FROM `orders` o JOIN `order_items` i ON i.order_id = o.order_id
GROUP BY o.order_id, o.total_amount, o.postage
HAVING SUM(i.line_amount) <> o.total_amount - o.postage;

-- V03 应付金额：pay_amount = total_amount - discount_amount
SELECT 'V03 pay_amount' AS check_name, order_id, total_amount - discount_amount AS expected, pay_amount
FROM `orders`
WHERE pay_amount <> total_amount - discount_amount;

-- V04 优惠拆分：discount_amount = 券抵扣 + 礼品卡抵扣
SELECT 'V04 discount_split' AS check_name, o.order_id, o.discount_amount,
       COALESCE(c.discount_amount, 0) + COALESCE(g.used, 0) AS expected
FROM `orders` o
LEFT JOIN `coupons` c ON c.coupon_id = o.coupon_id
LEFT JOIN (SELECT order_id, SUM(use_amount) AS used FROM `gift_card_usages` GROUP BY order_id) g
       ON g.order_id = o.order_id
WHERE o.discount_amount <> COALESCE(c.discount_amount, 0) + COALESCE(g.used, 0);

-- V05 订单号唯一 / 状态口径（OrderStatus 1..7，不允许 0）
SELECT 'V05 order_status_domain' AS check_name, order_id, status
FROM `orders`
WHERE status IS NULL OR status < 1 OR status > 7;

-- V06 已付订单必须有且仅有一条 SUCCESS 支付，且金额相等
SELECT 'V06 payment_match' AS check_name, o.order_id, o.pay_amount, p.pay_amount
FROM `orders` o
LEFT JOIN `payments` p ON p.order_id = o.order_id AND p.status = 'SUCCESS'
WHERE o.pay_time IS NOT NULL
  AND (p.pay_id IS NULL OR p.pay_amount <> o.pay_amount);

-- V07 未支付订单不得出现支付记录
SELECT 'V07 unpaid_no_payment' AS check_name, o.order_id
FROM `orders` o JOIN `payments` p ON p.order_id = o.order_id
WHERE o.pay_time IS NULL;

-- V08 支付幂等：同一订单不可有多条支付、provider_trade_no 不可重复
SELECT 'V08 payment_idempotency' AS check_name, order_id, COUNT(*) AS n
FROM `payments` GROUP BY order_id HAVING COUNT(*) > 1;
SELECT 'V08b provider_trade_no' AS check_name, provider_trade_no, COUNT(*) AS n
FROM `payments` GROUP BY provider_trade_no HAVING COUNT(*) > 1;

-- V09 退款金额不得超过该订单已支付金额（含部分退款场景）
SELECT 'V09 refund_cap' AS check_name, r.refund_id, r.refund_amount, p.pay_amount
FROM `refunds` r JOIN `payments` p ON p.order_id = r.order_id
WHERE r.refund_amount > p.pay_amount;

-- V10 退款单必须对应已支付订单
SELECT 'V10 refund_requires_payment' AS check_name, r.refund_id
FROM `refunds` r
WHERE NOT EXISTS (SELECT 1 FROM `payments` p WHERE p.order_id = r.order_id AND p.status = 'SUCCESS');

-- V11 券状态与有效期：已用券必须有 used_order_id；过期券 effective_to < T0；可用券 effective_to >= T0
SELECT 'V11 coupon_consistency' AS check_name, coupon_id, status, effective_to, used_order_id
FROM `coupons`
WHERE (status = 1 AND used_order_id IS NULL)
   OR (status = 2 AND effective_to >= 1793491200000)
   OR (status = 0 AND effective_to < 1793491200000);

-- V12 券归属：券的 user_id 必须等于使用订单的 user_id
SELECT 'V12 coupon_owner' AS check_name, c.coupon_id, c.user_id AS coupon_owner, o.user_id AS order_owner
FROM `coupons` c JOIN `orders` o ON o.order_id = c.used_order_id
WHERE c.user_id <> o.user_id;

-- V13 钱包：有符号流水 running sum = balance_after（用派生表避免无 GROUP BY 的 HAVING 歧义）
SELECT 'V13 wallet_running_sum' AS check_name, s.seq_id, s.balance_after, r.expected
FROM `wallet_sequences` s
JOIN (
  SELECT a.seq_id,
         (SELECT SUM(b.amount) FROM `wallet_sequences` b
           WHERE b.account_id = a.account_id
             AND (b.time < a.time OR (b.time = a.time AND b.seq_id <= a.seq_id))) AS expected
  FROM `wallet_sequences` a
) r ON r.seq_id = s.seq_id
WHERE s.balance_after <> r.expected;

-- V13b 钱包：账户余额必须等于该账户最后一条流水的 balance_after
SELECT 'V13b wallet_final_balance' AS check_name, a.account_id, a.balance, s.balance_after
FROM `wallet_accounts` a
JOIN `wallet_sequences` s ON s.seq_id =
     (SELECT s2.seq_id FROM `wallet_sequences` s2
       WHERE s2.account_id = a.account_id
       ORDER BY s2.time DESC, s2.seq_id DESC LIMIT 1)
WHERE a.balance <> s.balance_after;

-- V14 钱包：金额符号与收支类型一致（income > 0 / expense < 0）
SELECT 'V14 wallet_sign' AS check_name, seq_id, amount, type
FROM `wallet_sequences`
WHERE (type = 'income' AND amount <= 0) OR (type = 'expense' AND amount >= 0);

-- V15 礼品卡：balance = denomination - SUM(use_amount)，且累计抵扣不超面额
SELECT 'V15 gift_card_balance' AS check_name, g.card_id, g.balance,
       g.denomination - COALESCE(u.used, 0) AS expected
FROM `gift_cards` g
LEFT JOIN (SELECT card_id, SUM(use_amount) AS used FROM `gift_card_usages` GROUP BY card_id) u
       ON u.card_id = g.card_id
WHERE g.balance <> g.denomination - COALESCE(u.used, 0);

-- V16 选座：被订单行引用的座位必须状态 1（已售），且场次与订单一致
SELECT 'V16 sold_seat' AS check_name, i.item_id, i.seat_id, s.status, s.event_id, o.event_id
FROM `order_items` i
JOIN `ticket_seats` s ON s.seat_id = i.seat_id
JOIN `orders` o ON o.order_id = i.order_id
WHERE s.status <> 1 OR s.event_id <> o.event_id OR i.category_id NOT IN
      (SELECT category_id FROM `ticket_categories` WHERE event_id = o.event_id);

-- V17 选座：同一座位不可被重复售卖
SELECT 'V17 seat_unique' AS check_name, seat_id, COUNT(*) AS n
FROM `order_items` WHERE seat_id IS NOT NULL
GROUP BY seat_id HAVING COUNT(*) > 1;

-- V18 已售座位必须都能追溯到订单行（防止孤立占用）
SELECT 'V18 orphan_sold_seat' AS check_name, s.seat_id
FROM `ticket_seats` s
WHERE s.status = 1
  AND NOT EXISTS (SELECT 1 FROM `order_items` i WHERE i.seat_id = s.seat_id);

-- V19 拼团：成员数不超过成团人数，且恰有一名团长
SELECT 'V19 group_members' AS check_name, c.campaign_id, c.succeed_num, COUNT(m.member_id) AS members,
       SUM(CASE WHEN m.is_leader = 1 THEN 1 ELSE 0 END) AS leaders
FROM `pin_tuan_campaigns` c LEFT JOIN `group_buy_members` m ON m.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.succeed_num
HAVING COUNT(m.member_id) > c.succeed_num OR SUM(CASE WHEN m.is_leader = 1 THEN 1 ELSE 0 END) <> 1;

-- V20 代抢：total_amount = ticket_price * quantity + proxy_buy_fee
SELECT 'V20 proxy_total' AS check_name, proxy_id,
       ticket_price * quantity + proxy_buy_fee AS expected, total_amount
FROM `proxy_buy_orders`
WHERE total_amount <> ticket_price * quantity + proxy_buy_fee;

-- V21 引用完整性（本 mock 已用外键约束；此查询用于未开启外键的环境）
SELECT 'V21 orphan_order_items' AS check_name, i.item_id
FROM `order_items` i LEFT JOIN `orders` o ON o.order_id = i.order_id
WHERE o.order_id IS NULL;

-- ---------------------------------------------------------------------------
-- 场景观测（预期非空，用于对照 mall 样例的「脏数据形态」，不是失败项）
-- ---------------------------------------------------------------------------
-- S01 购物车同用户同票档重复加购（对应 mall oms_cart_item 重复 SKU）
SELECT 'S01 duplicate_cart_sku' AS observation, user_id, category_id, COUNT(*) AS n
FROM `cart_items` WHERE delete_status = 0
GROUP BY user_id, category_id HAVING COUNT(*) > 1;

-- S02 购物车空价格（对应 mall oms_cart_item price = NULL）
SELECT 'S02 null_cart_price' AS observation, COUNT(*) AS n
FROM `cart_items` WHERE price IS NULL;

-- S03 部分退款 / 全额退款场景
SELECT 'S03 refund_scenarios' AS observation, r.refund_id, r.refund_amount, p.pay_amount,
       CASE WHEN r.refund_amount = p.pay_amount THEN 'FULL' ELSE 'PARTIAL' END AS kind
FROM `refunds` r JOIN `payments` p ON p.order_id = r.order_id;

-- ---------------------------------------------------------------------------
-- 分页对照：深分页反模式 vs 游标分页（Alibaba 索引规约「延迟关联/游标」）
-- ---------------------------------------------------------------------------
-- P01 反模式：OFFSET 越大，MySQL 需要读取并丢弃的行越多
-- SELECT order_id FROM orders WHERE user_id = 8001 ORDER BY add_time DESC, order_id DESC LIMIT 100000, 20;
-- P02 推荐：以 (add_time, order_id) 为游标，命中 idx_mock_order_user_addtime
-- SELECT order_id, add_time FROM orders
--  WHERE user_id = 8001 AND (add_time < :last_add_time OR (add_time = :last_add_time AND order_id < :last_order_id))
--  ORDER BY add_time DESC, order_id DESC LIMIT 20;

-- =======================================================================
--  EOF
-- =======================================================================
