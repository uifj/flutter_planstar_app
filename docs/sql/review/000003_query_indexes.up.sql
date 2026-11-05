-- =======================================================================
--  Planstar 数据库评审 · 候选优化迁移
--  目标：MySQL 8.0 / InnoDB / utf8mb4 / 全新空库演示环境
--  生成：generate_review_sql.py（读取 01..11 根 DDL，不修改 000001 基线）
--  方言：MySQL 8.0。所有 DDL 均隐式提交，回滚依赖本包的 .down.sql 补偿脚本。
--  重要：本文件不是「已验证的性能优化」，索引项均为条件候选，
--        上线前必须用真实 EXPLAIN / 慢查询日志验证。
-- =======================================================================

-- -----------------------------------------------------------------------
-- 条件查询索引候选（全部为普通二级索引，可在空库安全回滚）
-- 每条都标注业务场景与证据；没有真实 QPS/执行计划，禁止声称性能收益。
-- 执行顺序：000002 之后、12_constraints.sql 之前或之后均可（索引名不与外键自动索引冲突）。
-- -----------------------------------------------------------------------

-- [planstar_order.orders] idx_order_user_addtime
--   场景：我的订单列表：按 user_id 过滤、按 add_time 倒序、以 order_id 做游标翻页
--   证据：lib/features/order/application/order_list_controller.dart → repository.findAll() 后在本地按 submittedAt/placedAt 排序
--   权衡：与现有 idx_order_user(user_id,status) 部分重叠；保留两者仅在「状态筛选」与「全量时间线」两种查询都真实存在时才合理
ALTER TABLE `planstar_order`.`orders` ADD INDEX `idx_order_user_addtime` (`user_id`,`add_time`,`order_id`);

-- [planstar_order.order_events] idx_orderev_order_time
--   场景：订单详情状态时间线：按 order_id 取事件并按发生时间排序
--   证据：order_events.order_id + add_time（05_order.sql:86,92）；现有 idx_orderev_order 仅覆盖 order_id
--   权衡：覆盖索引候选；若时间线永远按主键顺序读取则可不建
ALTER TABLE `planstar_order`.`order_events` ADD INDEX `idx_orderev_order_time` (`order_id`,`add_time`,`id`);

-- [planstar_catalog.activity_events] idx_event_act_start
--   场景：选票页场次日历：按演出取场次并按开演时间升序
--   证据：lib/features/catalog/ui/show_list_page.dart → firstSessionAt 升序排序
--   权衡：与现有 idx_event_act、idx_event_start 各重叠一部分；Alibaba 索引规约要求避免冗余，上线前用 EXPLAIN 二选一
ALTER TABLE `planstar_catalog`.`activity_events` ADD INDEX `idx_event_act_start` (`activity_id`,`start`,`id`);

-- [planstar_ticket.ticket_categories] idx_tc_event_status
--   场景：选票页票档列表：按场次 + 在售状态取票档
--   证据：04_ticket_inventory.sql:22,39；现有 idx_tc_event 仅覆盖场次
--   权衡：status 语义与取值尚未确认，条件索引；若 status 区分度极低则收益有限
ALTER TABLE `planstar_ticket`.`ticket_categories` ADD INDEX `idx_tc_event_status` (`activity_event_id`,`status`,`id`);

-- [planstar_marketing.coupons] idx_coupon_user_status_expiry
--   场景：我的优惠券：可用券按到期时间升序（临期排序）
--   证据：lib/features/marketing/coupon_page.dart / coupon.dart → daysUntilExpiry、isExpiringSoon 目前为客户端本地排序
--   权衡：当前 Flutter 为本地过滤排序，服务端尚无该查询契约；属预备候选，不应据此声称性能收益
ALTER TABLE `planstar_marketing`.`coupons` ADD INDEX `idx_coupon_user_status_expiry` (`user_id`,`status`,`effective_time_to`,`id`);

-- [planstar_payment.wallet_sequences] idx_walletseq_account_time
--   场景：钱包账户流水：按 account_id 分页并按时间倒序
--   证据：06_payment.sql:107,112；现有 idx_walletseq_user(user_id,time) 走用户维度
--   权衡：与现有索引口径不同（account_id vs user_id）；只有当服务端确实按账户查询时才需要
ALTER TABLE `planstar_payment`.`wallet_sequences` ADD INDEX `idx_walletseq_account_time` (`account_id`,`time`,`id`);

-- [planstar_community.reviews] idx_review_act_time
--   场景：演出详情评价列表：按演出取评价并按时间倒序 + 游标翻页
--   证据：08_community.sql:22-36（reviews 同时含 page_index/page_size/total_num/data 分页封装字段）
--   权衡：先要把分页封装字段从实体表中剥离，否则查询口径仍不明确
ALTER TABLE `planstar_community`.`reviews` ADD INDEX `idx_review_act_time` (`activity_id`,`add_time`,`id`);

-- [planstar_community.feeds] idx_feed_addtime_id  （替换 idx_feed_addtime）
--   场景：发现流游标分页：以 (add_time,id) 作为稳定游标，替代 OFFSET 深分页
--   证据：lib/features/discover/data/planstar_feed_api.dart → 客户端丢弃 next_page_key/has_more；基线已有 idx_feed_addtime(add_time)
--   权衡：替换而非新增；feeds 表目前把 next_page_key/has_more 当实体字段持久化，索引只解决排序，不解决建模问题
ALTER TABLE `planstar_community`.`feeds` DROP INDEX `idx_feed_addtime`;
ALTER TABLE `planstar_community`.`feeds` ADD INDEX `idx_feed_addtime_id` (`add_time`,`id`);

-- EOF
