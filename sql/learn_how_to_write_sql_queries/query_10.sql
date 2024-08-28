# Problem Description A:
# Finding n consecutive records where temperature is below zero. And table has a primary key.

# Tables Structure:
drop table if exists weather cascade;

create table if not exists weather (
    id 	int primary key,
	city varchar(50) not null,
	temperature int not null,
	day date not null
);

insert into weather values
(1, 'London', -1, STR_TO_DATE('2021-01-01', '%Y-%m-%d')),
(2, 'London', -2, STR_TO_DATE('2021-01-02', '%Y-%m-%d')),
(3, 'London', 4, STR_TO_DATE('2021-01-03', '%Y-%m-%d')),
(4, 'London', 1, STR_TO_DATE('2021-01-04', '%Y-%m-%d')),
(5, 'London', -2, STR_TO_DATE('2021-01-05', '%Y-%m-%d')),
(6, 'London', -5, STR_TO_DATE('2021-01-06', '%Y-%m-%d')),
(7, 'London', -7, STR_TO_DATE('2021-01-07', '%Y-%m-%d')),
(8, 'London', 5, STR_TO_DATE('2021-01-08', '%Y-%m-%d')),
(9, 'London', -20, STR_TO_DATE('2021-01-09', '%Y-%m-%d')),
(10, 'London', 20, STR_TO_DATE('2021-01-10', '%Y-%m-%d')),
(11, 'London', 22, STR_TO_DATE('2021-01-11', '%Y-%m-%d')),
(12, 'London', -1, STR_TO_DATE('2021-01-12', '%Y-%m-%d')),
(13, 'London', -2, STR_TO_DATE('2021-01-13', '%Y-%m-%d')),
(14, 'London', -2, STR_TO_DATE('2021-01-14', '%Y-%m-%d')),
(15, 'London', -4, STR_TO_DATE('2021-01-15', '%Y-%m-%d')),
(16, 'London', -9, STR_TO_DATE('2021-01-16', '%Y-%m-%d')),
(17, 'London', 0, STR_TO_DATE('2021-01-17', '%Y-%m-%d')),
(18, 'London', -10, STR_TO_DATE('2021-01-18', '%Y-%m-%d')),
(19, 'London', -11, STR_TO_DATE('2021-01-19', '%Y-%m-%d')),
(20, 'London', -12, STR_TO_DATE('2021-01-20', '%Y-%m-%d')),
(21, 'London', -11, STR_TO_DATE('2021-01-21', '%Y-%m-%d'));

select * from weather;

# Solution 1 (Personal Solution):
WITH cold_wather AS (
    SELECT *,
           DATEDIFF(day, LAG(day, 1, day) over (ORDER BY day)) AS last_date_diff,
           DATEDIFF(LEAD(day, 1, day) over (order by day), day) AS next_date_diff
    FROM weather
    WHERE temperature < 0
), cold_weather_typed AS (
    SELECT *,
           CASE
               WHEN last_date_diff <> 1 AND next_date_diff = 1 THEN 'F'
               WHEN last_date_diff = 1 AND next_date_diff = 1 THEN 'I'
               WHEN last_date_diff = 1 AND next_date_diff <> 1 THEN 'L'
               ELSE 'G'
           END AS row_type
    FROM cold_wather
), cold_weather_group_size AS (
    SELECT *,
           CASE
               WHEN row_type = 'F' THEN
                    (SELECT COUNT(*)
                     FROM cold_weather_typed AS cwt2
                     WHERE cwt2.day BETWEEN
                         cwt.day AND
                         (SELECT MIN(cwt3.day)
                          FROM cold_weather_typed AS cwt3
                          WHERE cwt3.day > cwt.day AND cwt3.row_type = 'L'))
               WHEN row_type = 'I' THEN
                    (SELECT COUNT(*)
                     FROM cold_weather_typed AS cwt2
                     WHERE cwt2.day BETWEEN
                         (SELECT MAX(cwt3.day)
                          FROM cold_weather_typed AS cwt3
                          WHERE cwt3.day < cwt.day AND cwt3.row_type = 'F') AND
                         (SELECT MIN(cwt3.day)
                          FROM cold_weather_typed AS cwt3
                          WHERE cwt3.day > cwt.day AND cwt3.row_type = 'L'))
               WHEN row_type = 'L' THEN
                    (SELECT COUNT(*)
                     FROM cold_weather_typed AS cwt2
                     WHERE cwt2.day BETWEEN
                         (SELECT MAX(cwt3.day)
                          FROM cold_weather_typed AS cwt3
                          WHERE cwt3.day < cwt.day AND cwt3.row_type = 'F') AND
                         cwt.day)
               ELSE 1
           END AS group_size
    FROM cold_weather_typed AS cwt
)
SELECT id, city, temperature, group_size
FROM cold_weather_group_size
WHERE group_size = 5;

# Solution 2 (Not Personal Solution):
with
	t1 as
		(select *,	id - row_number() over (order by id) as diff
		from weather w
		where w.temperature < 0),
	t2 as
		(select *,
		count(*) over (partition by diff order by diff) as cnt
		from t1)
select id, city, temperature, day
from t2
where t2.cnt = 3;

# Problem Description B:
# Finding n consecutive records where temperature is below zero. And table does not have primary key.

# Tables Structure:
create or replace view vw_weather as
select city, temperature from weather;

select * from vw_weather;

# Solution 1 (Personal Solution):
WITH t1 AS (
    SELECT *,
           ROW_NUMBER() OVER () AS row_n
    FROM vw_weather
), t2 AS (
    SELECT *,
           row_n - ROW_NUMBER() OVER (ORDER BY row_n) AS diff
    FROM t1
    WHERE temperature < 0
), t3 AS (
    SELECT *,
           COUNT(*) OVER (PARTITION BY diff) AS group_s
    FROM t2
)
SELECT city, temperature
FROM t3
WHERE group_s = 4;

# Solution 2 (Not Personal Solution):
with
	w as
		(select *, row_number() over () as id
		from vw_weather),
	t1 as
		(select *,	id - row_number() over (order by id) as diff
		from w
		where w.temperature < 0),
	t2 as
		(select *,
		count(*) over (partition by diff order by diff) as cnt
		from t1)
select city, temperature, id
from t2
where t2.cnt = 5;

# Problem Description C:
# Finding n consecutive records with consecutive date value.

# Tables Structure:
drop table if exists orders cascade;

create table if not exists orders (
    order_id varchar(20) primary key,
    order_date date not null
);

insert into orders values
('ORD1001', STR_TO_DATE('2021-Jan-01','%Y-%b-%d')),
('ORD1002', STR_TO_DATE('2021-Feb-01','%Y-%b-%d')),
('ORD1003', STR_TO_DATE('2021-Feb-02','%Y-%b-%d')),
('ORD1004', STR_TO_DATE('2021-Feb-03','%Y-%b-%d')),
('ORD1005', STR_TO_DATE('2021-Mar-01','%Y-%b-%d')),
('ORD1006', STR_TO_DATE('2021-Jun-01','%Y-%b-%d')),
('ORD1007', STR_TO_DATE('2021-Dec-25','%Y-%b-%d')),
('ORD1008', STR_TO_DATE('2021-Dec-26','%Y-%b-%d'));

select * from orders;

# Solution 1 (Personal Solution):
WITH t1 AS (
    SELECT *,
           DATEDIFF(order_date, LAG(order_date, 1, order_date) OVER (ORDER BY order_date)) AS last_date_diff,
           DATEDIFF(LEAD(order_date, 1, order_date) OVER (order by order_date), order_date) AS next_date_diff,
           ROW_NUMBER() OVER (ORDER BY order_date) AS id
    FROM orders
), t2 AS (
    SELECT *,
           id - ROW_NUMBER() OVER (ORDER BY order_date) AS diff
    FROM t1
    WHERE last_date_diff = 1 OR next_date_diff = 1
), t3 AS (
    SELECT *,
           COUNT(*) OVER (PARTITION BY diff) AS group_size
    FROM t2
)
SELECT order_id, order_date
FROM t3
WHERE group_size = 3;

# Solution 2 (Not Personal Solution):
with
  t1 as (
    select *,
        row_number() over(order by order_date) as rn,
	    DATE_ADD(order_date, INTERVAL -(row_number() over(order by order_date)) DAY) as diff
	from orders
  ),
  t2 as (
    select *, count(1) over (partition by diff) as cnt
	from t1
  )
select order_id, order_date
from t2
where cnt >= 3;
