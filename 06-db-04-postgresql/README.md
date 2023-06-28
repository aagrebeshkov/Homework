# Домашнее задание к занятию 4. «PostgreSQL»

## Задача 1

Используя Docker, поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL, используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:

- вывода списка БД,
- подключения к БД,
- вывода списка таблиц,
- вывода описания содержимого таблиц,
- выхода из psql.

<details>
<summary>Ответ</summary>

```bash
version: '3.4'

services:
  database:
    image: postgres:13
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
```

docker exec -it test_postgre_db-database-1 /bin/bash
```bash
# su - postgres
$ psql
```

- вывода списка БД:
```slq
postgres-# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

- подключения к БД:
```slq
\c <DB_NAME>
```

- вывода списка таблиц:
```slq
\dt
```

- вывода описания содержимого таблиц:
```slq
\dt[S+]
```

- выхода из psql:
```slq
\q
```

</details>


## Задача 2

Используя `psql`, создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления, и полученный результат.

<details>
<summary>Ответ</summary>

```bash
# su - postgres
$ psql
postgres=# CREATE DATABASE test_database;
postgres=# \q
```

Загрузил бекап в директорию '/var/lib/docker/volumes/test_postgre_db_gpbackup/_data/'
```sql
# su - postgres
$ psql test_database < /var/lib/postgresql/backup/test_dump.sql
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```

```sql
postgres@a1ef4a94580a:~$ psql
postgres=# \c test_database
test_database=# ANALYZE;
test_database=# SELECT * FROM pg_stats WHERE tablename = 'orders' ORDER BY avg_width DESC LIMIT 1;
 schemaname | tablename | attname | inherited | null_frac | avg_width | n_distinct | most_common_vals | most_common_freqs |                                                                 histogram_bounds
                                                                  | correlation | most_common_elems | most_common_elem_freqs | elem_count_histogram 
------------+-----------+---------+-----------+-----------+-----------+------------+------------------+-------------------+---------------------------------------------------------------------------------
------------------------------------------------------------------+-------------+-------------------+------------------------+----------------------
 public     | orders    | title   | f         |         0 |        16 |         -1 |                  |                   | {"Adventure psql time",Dbiezdmin,"Log gossips","Me and my bash-pet","My little d
atabase","Server gravity falls","WAL never lies","War and peace"} |  -0.3809524 |                   |                        | 
(1 row)
```

</details>


## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам как успешному выпускнику курсов DevOps в Нетологии предложили
провести разбиение таблицы на 2: шардировать на orders_1 - price>499 и orders_2 - price<=499.

Предложите SQL-транзакцию для проведения этой операции.

Можно ли было изначально исключить ручное разбиение при проектировании таблицы orders?

<details>
<summary>Ответ</summary>

```sql
CREATE TABLE public.orders_1 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);

CREATE TABLE public.orders_2 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);

INSERT INTO orders_1 (id, title, price) SELECT * FROM orders WHERE price > 499;
INSERT INTO orders_2 (id, title, price) SELECT * FROM orders WHERE price <= 499;
```

При проектировании таблицы orders надо было сразу данные разбивать по двум таблицам.

</details>


## Задача 4

Используя утилиту `pg_dump`, создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

<details>
<summary>Ответ</summary>

Создание бекапа БД `test_database`:
```bash
pg_dump -U postgres test_database > /var/lib/postgresql/backup/test_database_`date +%Y_%m_%d-%H_%M`.dump
```

Для добавления уникальности значения столбца `title` для таблиц необходимо добавить создание CONSTRAINT, их названия должны быть разными:

```sql
REATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0,
    CONSTRAINT orders_title_unique UNIQUE (title)
);


CREATE TABLE public.orders_1 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0,
    CONSTRAINT orders_1_title_unique UNIQUE (title)
);


CREATE TABLE public.orders_2 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0,
    CONSTRAINT orders_2_title_unique UNIQUE (title)
);
```

</details>


---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

