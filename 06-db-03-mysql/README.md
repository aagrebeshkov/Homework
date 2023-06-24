# Домашнее задание к занятию 3. «MySQL»

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/blob/virt-11/additional/README.md).

## Задача 1

Используя Docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h`, получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из её вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с этим контейнером.

<details>
<summary>Ответ</summary>
Используя Docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

docker-compose.yml:
```bash
version: '3.4'

services:
  database:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: 12345678
      MYSQL_ALLOW_EMPTY_PASSWORD: yes
      MYSQL_DATABASE: test_db
      TZ: Europe/Moscow
    ports:
      - 3306:3306
    volumes:
      - ./data:/var/lib/mysql
      - ./backup:/var/lib/mysql_backup
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost"]
      interval: 10s
      timeout: 10s
      retries: 20
```

Восстановиться из бекапа:
```bash
# docker exec -it test_mysql_db-database-1 /bin/bash
bash-4.4# mysql -u root -p test_db < /var/lib/mysql_backup/test_dump.sql
Enter password: 
```

Перейдите в управляющую консоль `mysql` внутри контейнера.
```bash
# mysql -u root -p
```

Используя команду `\h`, получите список управляющих команд.
```sql
mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file

For server side help, type 'help contents'
```

Найдите команду для выдачи статуса БД и **приведите в ответе** из её вывода версию сервера БД.
```sql
mysql> status
--------------
mysql  Ver 8.0.33 for Linux on x86_64 (MySQL Community Server - GPL)
...
Server version:     8.0.33 MySQL Community Server - GPL
...
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```sql
mysql> use test_db;
mysql> SELECT DATABASE();
+------------+
| DATABASE() |
+------------+
| test_db    |
+------------+

mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

**Приведите в ответе** количество записей с `price` > 300.
```sql
mysql> select * from orders where price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```
</details>


## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:

- плагин авторизации mysql_native_password
- срок истечения пароля — 180 дней 
- количество попыток авторизации — 3 
- максимальное количество запросов в час — 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James".

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES, получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

<details>
<summary>Ответ</summary>

```sql
# mysql -u root -p

CREATE USER test IDENTIFIED WITH mysql_native_password BY 'test-pass'
  WITH MAX_QUERIES_PER_HOUR 100
  PASSWORD EXPIRE INTERVAL 180 DAY
  FAILED_LOGIN_ATTEMPTS 3
  ATTRIBUTE '{"surname": "Pretty", "name": "James"}';

GRANT SELECT ON test_db.* TO 'test';

mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user = 'test';
+------+------+----------------------------------------+
| USER | HOST | ATTRIBUTE                              |
+------+------+----------------------------------------+
| test | %    | {"name": "James", "surname": "Pretty"} |
+------+------+----------------------------------------+

```

</details>


## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`,
- на `InnoDB`.

<details>
<summary>Ответ</summary>

```sql
# mysql -u root -p
mysql> SET profiling = 1;

mysql> SHOW PROFILES;
+----------+------------+----------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                |
+----------+------------+----------------------------------------------------------------------+
|        1 | 0.00084925 | SET profiling = 1                                                    |
|        2 | 0.00164400 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user = 'test' |
+----------+------------+----------------------------------------------------------------------+
```
Покажет время выполнения запросов.

```sql
mysql> SELECT TABLE_SCHEMA, TABLE_NAME, ENGINE FROM INFORMATION_SCHEMA.TABLES
    -> WHERE TABLE_SCHEMA = 'test_db';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+

-- Запрос на InnoDB
mysql> SELECT * FROM test_db.orders;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.01 sec)

mysql> SHOW PROFILES;
+----------+------------+------------------------------+
| Query_ID | Duration   | Query                        |
+----------+------------+------------------------------+
|        1 | 0.00065475 | SELECT * FROM test_db.orders |
+----------+------------+------------------------------+
1 row in set, 1 warning (0.00 sec)


-- Смена ENGINE на MyISAM
mysql> use test_db;
mysql> ALTER TABLE orders ENGINE = 'MyISAM';
mysql> SELECT TABLE_SCHEMA, TABLE_NAME, ENGINE FROM INFORMATION_SCHEMA.TABLES
    -> WHERE TABLE_SCHEMA = 'test_db';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | MyISAM |
+--------------+------------+--------+

mysql> SELECT * FROM test_db.orders;
mysql> SHOW PROFILES;
+----------+------------+-------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                 |
+----------+------------+-------------------------------------------------------------------------------------------------------+
|        1 | 0.00065475 | SELECT * FROM test_db.orders                                                                          |
|        2 | 0.00031375 | ALTER TABLE orders ENGINE = 'MyISAM'                                                                  |
|        3 | 0.00104400 | SELECT DATABASE()                                                                                     |
|        4 | 0.00239475 | show databases                                                                                        |
|        5 | 0.00167175 | show tables                                                                                           |
|        6 | 0.04415600 | ALTER TABLE orders ENGINE = 'MyISAM'                                                                  |
|        7 | 0.00059600 | SELECT * FROM test_db.orders                                                                          |
|        8 | 0.00192800 | SELECT TABLE_SCHEMA, TABLE_NAME, ENGINE FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'test_db' |
|        9 | 0.00057225 | SELECT * FROM test_db.orders                                                                          |
+----------+------------+-------------------------------------------------------------------------------------------------------+
```
Запрос к таблице orders выполнился быстрее на движке MyISAM.

</details>


## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):

- скорость IO важнее сохранности данных;
- нужна компрессия таблиц для экономии места на диске;
- размер буффера с незакомиченными транзакциями 1 Мб;
- буффер кеширования 30% от ОЗУ;
- размер файла логов операций 100 Мб.

Приведите в ответе изменённый файл `my.cnf`.

<details>
<summary>Ответ</summary>

cat /etc/my.cnf
```bash
[mysqld]

# CUSTOM SETTINGS
innodb_flush_method = O_DSYNC
innodb_file_per_table = 1
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 4G
innodb_log_file_size = 100M

skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/
```

- скорость IO важнее сохранности данных;<br>
    изменить innodb_flush_method = O_DSYNC<br>
    Проверить: show variables like 'innodb_flush_method';
- нужна компрессия таблиц для экономии места на диске; <br>
    innodb_file_per_table = 1<br>
    Проверить: show variables like 'innodb_file_per_table';
- размер буффера с незакомиченными транзакциями 1 Мб;<br>
    innodb_log_buffer_size = 1M
- буффер кеширования 30% от ОЗУ;<br>
    innodb_buffer_pool_size
- размер файла логов операций 100 Мб.<br>
    увеличить innodb_log_file_size = 100M<br>
    Проверить: SHOW GLOBAL VARIABLES LIKE '%innodb_log%';

</details>


---

### Как оформить ДЗ

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

