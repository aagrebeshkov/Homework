# Домашнее задание к занятию 2. «SQL»

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/blob/virt-11/additional/README.md).

## Задача 1

Используя Docker, поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose-манифест.

<details>
<summary>Ответ</summary>

    version: '3.4'

    services:
      database:
        image: postgres:12
        restart: always
        environment:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          TZ: Europe/Moscow
        ports:
          - 5432:5432
        volumes:
          - pgdata:/var/lib/postgresql/data
          - gpbackup:/var/lib/postgresql/backup
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U postgres -d postgres"]
          interval: 10s
          timeout: 10s
          retries: 20
    
    volumes:
      pgdata:
      gpbackup:

</details>



## Задача 2

В БД из задачи 1: 

- создайте пользователя test-admin-user и БД test_db;
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже);
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db;
- создайте пользователя test-simple-user;
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE этих таблиц БД test_db.

Таблица orders:

- id (serial primary key);
- наименование (string);
- цена (integer).

Таблица clients:

- id (serial primary key);
- фамилия (string);
- страна проживания (string, index);
- заказ (foreign key orders).

Приведите:

- итоговый список БД после выполнения пунктов выше;
- описание таблиц (describe);
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db;
- список пользователей с правами над таблицами test_db.

<details>
<summary>Ответ</summary>

Выполнение задания:
```sql
# docker-compose up -d
# docker exec -it testdb-database-1 /bin/bash
# su - postgres
$ psql
postgres=# CREATE USER "test-admin-user" WITH PASSWORD 'admin123';
postgres=# CREATE DATABASE test_db;
postgres=# \q
$ psql -d test_db

test_db=# CREATE TABLE orders (
    id serial primary key,
    name varchar(20),
    price int
);

test_db=# CREATE TABLE clients (
    id serial primary key,
    surname varchar(20),
    сountry varchar(20),
    orderid INT REFERENCES orders (id)
);

test_db=# CREATE INDEX ix_clients_сountry ON clients (сountry);
test_db=# GRANT ALL PRIVILEGES ON DATABASE test_db TO "test-admin-user";
test_db=# CREATE USER "test-simple-user" WITH PASSWORD 'simple123';
test_db=# GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE orders, clients TO "test-simple-user";
```

Итоговый список БД после выполнения пунктов выше:
```sql
postgres=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges        
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```

Описание таблиц (describe):
```sql
test_db=# \d+ orders
                                                       Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 name   | character varying(20) |           |          |                                    | extended |              | 
 price  | integer               |           |          |                                    | plain    |              | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_orderid_fkey" FOREIGN KEY (orderid) REFERENCES orders(id)
Access method: heap


test_db=# \d+ clients
                                                        Table "public.clients"
  Column  |         Type          | Collation | Nullable |               Default               | Storage  | Stats target | Description 
----------+-----------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id       | integer               |           | not null | nextval('clients_id_seq'::regclass) | plain    |              | 
 surname  | character varying(20) |           |          |                                     | extended |              | 
 сountry | character varying(20) |           |          |                                     | extended |              | 
 orderid  | integer               |           |          |                                     | plain    |              | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "ix_clients_сountry" btree ("сountry")
Foreign-key constraints:
    "clients_orderid_fkey" FOREIGN KEY (orderid) REFERENCES orders(id)
Access method: heap
```

SQL-запрос для выдачи списка пользователей с правами над таблицами test_db:
```sql
SELECT table_name, array_agg(privilege_type), grantee
FROM information_schema.table_privileges
WHERE table_name = 'orders' OR table_name = 'clients'
GROUP BY table_name, grantee;
```

Список пользователей с правами над таблицами test_db:
```sql
 table_name |                         array_agg                         |     grantee      
------------+-----------------------------------------------------------+------------------
 clients    | {INSERT,TRIGGER,REFERENCES,TRUNCATE,DELETE,UPDATE,SELECT} | test-admin-user
 clients    | {DELETE,INSERT,SELECT,UPDATE}                             | test-simple-user
 orders     | {INSERT,TRIGGER,REFERENCES,TRUNCATE,DELETE,UPDATE,SELECT} | test-admin-user
 orders     | {DELETE,SELECT,UPDATE,INSERT}                             | test-simple-user
(4 rows)
```

</details>


## Задача 3

Используя SQL-синтаксис, наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL-синтаксис:
- вычислите количество записей для каждой таблицы.

Приведите в ответе:

    - запросы,
    - результаты их выполнения.


<details>
<summary>Ответ</summary>

```sql
INSERT INTO orders ("name", "price") VALUES ('Шоколад', 10);
INSERT INTO orders ("name", "price") VALUES ('Принтер', 3000);
INSERT INTO orders ("name", "price") VALUES ('Книга', 500);
INSERT INTO orders ("name", "price") VALUES ('Монитор', 7000);
INSERT INTO orders ("name", "price") VALUES ('Гитара', 4000);

INSERT INTO clients ("surname", "сountry") VALUES ('Иванов Иван Иванович', 'USA');
INSERT INTO clients ("surname", "сountry") VALUES ('Петров Петр Петрович', 'Canada');
INSERT INTO clients ("surname", "сountry") VALUES ('Иоганн Себастьян Бах', 'Japan');
INSERT INTO clients ("surname", "сountry") VALUES ('Ронни Джеймс Дио', 'Russia');
INSERT INTO clients ("surname", "сountry") VALUES ('Ritchie Blackmore', 'Russia');
```

Вычислите количество записей для каждой таблицы:
```sql
SELECT count(*) FROM orders;test_db=# SELECT count(*) FROM orders;
 count 
-------
     5
(1 row)



test_db=# SELECT count(*) FROM clients;
 count 
-------
     5
(1 row)
```

</details>


## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys, свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения этих операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод этого запроса.
 
Подсказка: используйте директиву `UPDATE`.


<details>
<summary>Ответ</summary>

```sql
UPDATE clients SET orderid = 3 WHERE surname = 'Иванов Иван Иванович';
UPDATE clients SET orderid = 4 WHERE surname = 'Петров Петр Петрович';
UPDATE clients SET orderid = 5 WHERE surname = 'Иоганн Себастьян Бах';
```

```sql
test_db=# SELECT surname, сountry, name, price FROM orders O INNER JOIN clients C ON O.id = C.orderid;
                surname                 | сountry |      name      | price 
----------------------------------------+----------+----------------+-------
 Иванов Иван Иванович | USA      | Книга     |   500
 Петров Петр Петрович | Canada   | Монитор |  7000
 Иоганн Себастьян Бах | Japan    | Гитара   |  4000
(3 rows)
```

</details>


## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните, что значат полученные значения.

<details>
<summary>Ответ</summary>

```sql
test_db=# EXPLAIN SELECT * FROM clients;
                         QUERY PLAN                         
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..15.30 rows=530 width=124)
(1 row)
```
Seq Scan - последовательное чтение данных таблицы.
cost=0.00..15.30 - Первое значение 0.00 — затраты на получение первой строки. Второе — 15.30 — затраты на получение всех строк.
rows=530 - приблизительное количество возвращаемых строк при выполнении операции Seq Scan.
width=124 - средний размер одной строки в байтах

После обновления статистики информация по выполнению запроса получилась более актуальная:
```sql
test_db=# ANALYZE clients;
ANALYZE
test_db=# EXPLAIN SELECT * FROM clients;
                       QUERY PLAN                       
--------------------------------------------------------
 Seq Scan on clients  (cost=0.00..1.05 rows=5 width=47)
(1 row)
```

</details>


## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. задачу 1).

Остановите контейнер с PostgreSQL, но не удаляйте volumes.

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

<details>
<summary>Ответ</summary>
Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов:

```bash
pg_dump -U postgres test_db > /var/lib/postgresql/backup/test_db_`date +%Y_%m_%d-%H_%M`.dump
```

Остановите контейнер с PostgreSQL, но не удаляйте volumes:
```bash
docker-compose down
```


Поднимите новый пустой контейнер с PostgreSQL.
```bash
docker volume rm testdb_pgdata
docker-compose up -d
```

Восстановите БД test_db в новом контейнере.

```bash
# docker exec -it testdb-database-1 /bin/bash
# psql -U postgres
postgres=# CREATE USER "test-admin-user" WITH PASSWORD 'admin123';
postgres=# CREATE USER "test-simple-user" WITH PASSWORD 'simple123';

# psql -U postgres < /var/lib/postgresql/backup/test_db_2023_06_21-17_13.dump
```

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
```bash
# pg_dump -U postgres test_db > /var/lib/postgresql/backup/test_db_`date +%Y_%m_%d-%H_%M`.dump
# psql -U postgres < /var/lib/postgresql/backup/test_db_2023_06_21-17_13.dump
```

</details>


---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

