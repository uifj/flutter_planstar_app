-- ========================================================================
--  sql_new（已修复版）· 01_init_databases.sql
--  来源: docs/sql/01_init_databases.sql  |  生成: tools/build_sql_new.py
--  与基线的差异:
--    R1 表尾显式 COLLATE=utf8mb4_unicode_ci（库/表/列三层排序规则统一）
--    R2 8 处关联 ID 由 INT 对齐为 BIGINT（消除 fk_pin_tuan_orders_pin_tuan_id 阻塞）
--    R3 4 处元数据代理主键补 COMMENT
--  为什么这样设计: 以上三项不改变列语义、不拒绝历史数据、不影响 267 个 REST 契约，
--    属于可确定性执行的规范类修复；会改变业务口径的提案全部留在 optional/PROPOSALS.sql。
--  基线 docs/sql/ 未被修改；本目录可独立用于 MySQL 8.0 全新空库安装。
--  验证边界: 见 VALIDATION.md（未做真实 MySQL 8.0 执行 / EXPLAIN / 压测 / HA 验证）。
-- ========================================================================

-- ========================================================================
--  01_init_databases.sql · 初始化企划星各服务库
-- ========================================================================
--  目录结构参考: github.com/arixbit/kratos-shop/sql/01_init_databases.sql
--  差异: 参考仓库用 PostgreSQL 的 \gexec 幂等建库；本文件保持 MySQL 8.0，
--        使用 CREATE DATABASE IF NOT EXISTS，语义等价且可直接执行。
--  参考仓库 6 个库；本票务域拆为 9 个库（见下）。
-- ========================================================================

-- planstar_user · 用户与账号
CREATE DATABASE IF NOT EXISTS `planstar_user` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_catalog · 基础字典与演出商品
CREATE DATABASE IF NOT EXISTS `planstar_catalog` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_ticket · 票档 / 座位 / 库存
CREATE DATABASE IF NOT EXISTS `planstar_ticket` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_order · 订单
CREATE DATABASE IF NOT EXISTS `planstar_order` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_payment · 支付 / 退款 / 钱包 / 礼品卡
CREATE DATABASE IF NOT EXISTS `planstar_payment` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_marketing · 营销资产
CREATE DATABASE IF NOT EXISTS `planstar_marketing` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_community · 内容与社区 UGC
CREATE DATABASE IF NOT EXISTS `planstar_community` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_content · 运营位 / 搜索 / 增长
CREATE DATABASE IF NOT EXISTS `planstar_content` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- planstar_meta · 枚举字典 + 逆向证据目录
CREATE DATABASE IF NOT EXISTS `planstar_meta` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ========================================================================
--  后续文件按 02 → 12 顺序执行；每个 NN_<域>.sql 开头 USE 对应服务库。
-- ========================================================================
