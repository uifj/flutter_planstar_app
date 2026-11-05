# sql_rebuildnew — 完整可执行 SQL（已在真实 MySQL 实跑）

> 由 `tools/build_sql_rebuildnew.py` 从 `docs/sql_new/` 生成。
> `docs/sql/` 基线与 `docs/sql_new/` 均**未被修改**。

## 这是什么

把 `sql_new` 里分散的 13 个编号文件整理成一份**顺序正确、可一次性执行**的完整 SQL，
并在本机 Docker 的 MySQL 上真实跑通，用来回答「整套建库脚本到底有没有问题」。

- `00_all.sql` —— **一键完整安装，0 ERROR / 0 WARNING**（9 库 / 89 表 / 4 组证据种子 / 61 条外键 / 8 个条件索引）
- `00_all_faithful.sql` —— 忠实原样版：SQL 正文与 `sql_new` 逐语句一致，仅替换过时头部；
  在 MySQL 8.4 上 0 ERROR / **119 条 Warning 1681**（全部来自 `TINYINT(1)` 显示宽度弃用）
- `01..13_*.sql` —— 分文件副本（已应用 R4），便于逐段 `SOURCE` 或复用
- `90_teardown.sql` —— 逆序删库（**破坏性**，执行前确认无业务数据）
- `verify.sql` —— 实跑后 `information_schema` 复核查询
- `preflight.json` —— 静态预检：61 条外键 / 9 条索引语句的引用与类型核对
- `optional/PROPOSALS.sql` —— 只读副本，**全注释、0 可执行语句**（Q1–Q10 未确认，不落地）
- `validation.json` / `VALIDATION.md` / `index.html` —— 16 项实跑校验结果与可视化报告
- `run_log_clean.txt` / `run_log_faithful.txt` —— 两次真实执行的 stdout / stderr 原始日志
- `manifest.json` —— 源文件 sha256 与生成物清单；`tools/` —— 可复现生成器与校验器

### R4（本目录唯一新增的文本改动）

`sql_new` 的 119 个 `TINYINT(1)` 在 MySQL 8.4.10 上会触发 119 条
`Warning 1681: Integer display width is deprecated`。显示宽度不影响存储 / 值域 /
可空性 / 默认值，且本库经 JSON REST 访问、无 JDBC `tinyInt1isBit` 依赖，
因此 `00_all.sql` 把它归一化为 `TINYINT`，实跑 **0 告警**。
需要逐字节对照时改用 `00_all_faithful.sql`。

## 执行顺序（不可调换）

```
01_init_databases.sql   ->  CREATE DATABASE x 9
02..09_<域>.sql         ->  USE <库> + CREATE TABLE（89 张）
10_dict_enums.sql       ->  dict_enums + 143 条字典种子
11_rev_evidence.sql     ->  3 张证据表 + 1736 / 267 / 217 行证据
12_constraints.sql      ->  61 条推断外键（含 24 条跨库，需同实例）
13_query_indexes.sql    ->  8 个条件索引（feeds 先 DROP 再 ADD）
```

`00_all.sql` 已按此顺序拼接；各分文件自带 `USE`，12/13 用全限定名，不依赖当前库。

## 本机实跑方式

镜像 `8dbcf531a03a` 是 **`mysql:8`（实际 8.4.10 LTS）的镜像 ID**，不是容器 ID；
本机此前没有由它创建的容器，因此基于该镜像新建了验证容器：

```bash
docker run -d --name planstar-mysql-verify \
  -e MYSQL_ROOT_PASSWORD='PlanstarVerify@2026' -e MYSQL_ROOT_HOST='%' \
  -p 13307:3306 8dbcf531a03a

docker exec -i -e MYSQL_PWD='PlanstarVerify@2026' planstar-mysql-verify \
  mysql -uroot --default-character-set=utf8mb4 < 00_all.sql
```

复核：`python tools/verify_mysql.py`（内部通过 `docker exec` 查询 information_schema）。

## 实跑结果（真实 MySQL，非静态推断）

| 项 | 结果 |
| --- | --- |
| `00_all.sql`（干净版） | **0 ERROR / 0 WARNING**；stdout 与 stderr 均为 0 字节 |
| `00_all_faithful.sql`（原样版） | 0 ERROR / 119 WARNING，全部为 Code 1681 |
| 库 / 表 / 列 / 索引 | 9 / 89 / 1,444 / 182 |
| 引擎与排序规则 | 89 张表全部 `InnoDB + utf8mb4_unicode_ci` |
| 外键 | 61 条定义 = 61 条 `REFERENTIAL_CONSTRAINTS`；其中 24 条跨库全部成功 |
| 外键强制生效 | 同库 / 跨库各插入一条必违例记录，均被 `ERROR 1452` 拒绝，子表残留 0 行 |
| 证据种子 | 143 / 1,736 / 267 / 217（合计 2,363 行） |
| 列注释 / JSON 列 | 0 个缺注释 / 222 个 JSON 列 |
| 校验 | `validation.json` = **PASS 16/16**（见 `VALIDATION.md` / `index.html`） |

日志：`run_log_clean.txt` / `run_log_faithful.txt`；机器可读：`validation.json`、
`preflight.json`、`manifest.json`。

## 边界（务必沿用）

- 实跑环境是 **MySQL 8.4.10 LTS**，不是 8.0；DDL 方言按 8.0 编写，8.4 上零错误通过。
- **未做** EXPLAIN / 索引选择性 / 锁竞争 / QPS / 复制 / 高可用 / 分区 / 归档实测。
- **未落地** deep_review 的 P01–P17 语义提案；`sql_new` 的 D-01..D-17 结构性结论仍然成立
  （payments 仍是 PayInfo DTO 镜像、仍无座位锁 / 库存流水、双状态码仍待标定）。
  「能跑通」只证明 DDL 语法与引用完整，不等于「符合生产业务逻辑」。
- `90_teardown.sql` 是破坏性删库，不是数据恢复型回滚；DDL 隐式提交，`ROLLBACK` 无效。

## 复现

```bash
cd docs/sql_rebuildnew
python tools/build_sql_rebuildnew.py
python tools/verify_mysql.py
```
