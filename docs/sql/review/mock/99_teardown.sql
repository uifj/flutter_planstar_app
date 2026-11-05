-- =======================================================================
--  Planstar 票务 Mock · 回滚 / 清理（MySQL 8.0）
--  ⚠ 此脚本只删除隔离库 planstar_mock_ticketing，不触碰 9 个业务库。
--  ⚠ DROP DATABASE 不可回滚且隐式提交；执行前请确认库名无误。
--  重新生成：00_schema.sql → 01_seed.sql → 02_validate.sql
-- =======================================================================

DROP DATABASE IF EXISTS `planstar_mock_ticketing`;

-- EOF
