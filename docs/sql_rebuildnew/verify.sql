-- ========================================================================
--  sql_rebuildnew · verify.sql —— 实跑后的 information_schema 复核
--  在 00_all.sql 执行完成后运行；全部结果由 verify_mysql.py 写入 validation.json。
-- ========================================================================

SELECT VERSION() AS server_version;

SELECT SCHEMA_NAME, DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME LIKE 'planstar_%' ORDER BY SCHEMA_NAME;

SELECT COUNT(*) AS table_count FROM information_schema.TABLES
WHERE TABLE_SCHEMA LIKE 'planstar_%' AND TABLE_TYPE = 'BASE TABLE';

SELECT COUNT(*) AS column_count FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA LIKE 'planstar_%';

SELECT COUNT(DISTINCT TABLE_SCHEMA, TABLE_NAME, INDEX_NAME) AS index_count
FROM information_schema.STATISTICS WHERE TABLE_SCHEMA LIKE 'planstar_%';

SELECT COUNT(*) AS fk_count FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA LIKE 'planstar_%' AND CONSTRAINT_TYPE = 'FOREIGN KEY';

SELECT ENGINE, TABLE_COLLATION, COUNT(*) AS n FROM information_schema.TABLES
WHERE TABLE_SCHEMA LIKE 'planstar_%' AND TABLE_TYPE = 'BASE TABLE'
GROUP BY ENGINE, TABLE_COLLATION ORDER BY n DESC;

SELECT COUNT(*) AS uncommented_columns FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA LIKE 'planstar_%' AND (COLUMN_COMMENT IS NULL OR COLUMN_COMMENT = '');

SELECT 'dict_enums' AS t, COUNT(*) AS n FROM `planstar_meta`.`dict_enums`
UNION ALL SELECT '_rev_dto_field_catalog', COUNT(*) FROM `planstar_meta`.`_rev_dto_field_catalog`
UNION ALL SELECT '_rev_endpoint_catalog', COUNT(*) FROM `planstar_meta`.`_rev_endpoint_catalog`
UNION ALL SELECT '_rev_dto_table_mapping', COUNT(*) FROM `planstar_meta`.`_rev_dto_table_mapping`;

SELECT COUNT(*) AS fk_constraints_live FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA LIKE 'planstar_%';
