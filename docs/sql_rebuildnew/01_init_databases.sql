-- ========================================================================
--  sql_rebuildnew · 01_init_databases.sql
--  来源  : docs/sql_new（已含 R1 显式 COLLATE / R2 8 处 BIGINT 对齐 / R3 4 处注释）
--  用途  : 在真实 MySQL（Docker 镜像 8dbcf531a03a，mysql:8 / 8.4.10 LTS）上完整实跑验证。
--  与 sql_new 的差异:
--     (a) 替换 sql_new 中「未做真实 MySQL 执行」的过时生成头部；
--     (b) R4 确定性规范修复：TINYINT(1) -> TINYINT，消除 MySQL 8.4 的 1681
--         「整数显示宽度已弃用」告警。显示宽度不影响存储、值域、可空性、默认值，
--         本库经 JSON REST 访问、无 JDBC tinyInt1isBit 依赖，故语义等价。
--  原样版本（未做 R4，119 条 1681 告警）见 00_all_faithful.sql。
--  未执行 deep_review 的 P01–P17 语义提案（Q1–Q10 未确认）。
--  实跑结果: 见 VALIDATION.md / validation.json / run_log_clean.txt
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
