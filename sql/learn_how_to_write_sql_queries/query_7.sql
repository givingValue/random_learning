# Problem Description:
# From the weather table, fetch all the records when London had extremely cold temperature for 3 consecutive days or more.
# Note: Weather is considered to be extremely cold then its temperature is less than zero.

# Tables Structure:
drop table if exists weather;

create table weather (
    id int,
    city varchar(50),
    temperature int,
    day date
);

insert into weather values
(1, 'London', -1, CAST('2021-01-01' AS DATE)),
(2, 'London', -2, CAST('2021-01-02' AS DATE)),
(3, 'London', 4, CAST('2021-01-03' AS DATE)),
(4, 'London', 1, CAST('2021-01-04' AS DATE)),
(5, 'London', -2, CAST('2021-01-05' AS DATE)),
(6, 'London', -5, CAST('2021-01-06' AS DATE)),
(7, 'London', -7, CAST('2021-01-07' AS DATE)),
(8, 'London', 5, CAST('2021-01-08'AS DATE));

select * from weather;

# Solution 1 (Personal Solution):
drop table if exists weather2;

create table weather2 (
    id int,
    city varchar(50),
    temperature int,
    day date
);

insert into weather2
SELECT (ones.num + tens.num) AS id,
       'London' AS city,
       (RAND() * 10) - 6 AS temperature,
       DATE_ADD('2020-01-01', INTERVAL (ones.num + tens.num) DAY) AS day
FROM
    (SELECT 0 AS num UNION
    SELECT 1 AS num UNION
    SELECT 2 AS num UNION
    SELECT 3 AS num UNION
    SELECT 4 AS num UNION
    SELECT 5 AS num UNION
    SELECT 6 AS num UNION
    SELECT 7 AS num UNION
    SELECT 8 AS num UNION
    SELECT 9 AS num) AS ones
    CROSS JOIN
        (SELECT 0 AS num UNION
        SELECT 10 AS num UNION
        SELECT 20 AS num) AS tens
ORDER BY 1;

select * from weather2;

WITH cold_weather AS (
    SELECT *,
           DATEDIFF(day, LAG(day, 1, day) over (ORDER BY day)) AS last_date_diff,
           DATEDIFF(LEAD(day, 1, day) over (order by day), day) AS next_date_diff
    FROM weather2
    WHERE temperature < 0
), cold_weather_typed AS (
    SELECT *,
           CASE
               WHEN last_date_diff <> 1 AND next_date_diff = 1 THEN 'F'
               WHEN last_date_diff = 1 AND next_date_diff = 1 THEN 'I'
               WHEN last_date_diff = 1 AND next_date_diff <> 1 THEN 'L'
               ELSE 'G'
           END AS row_type
    FROM cold_weather
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
SELECT id, group_size
FROM cold_weather_group_size;

# Solution 2 (Not Personal Solution):
select id, city, temperature, day
from (
    select *,
        case when temperature < 0
              and lead(temperature) over(order by day) < 0
              and lead(temperature,2) over(order by day) < 0
        then 'Y'
        when temperature < 0
              and lead(temperature) over(order by day) < 0
              and lag(temperature) over(order by day) < 0
        then 'Y'
        when temperature < 0
              and lag(temperature) over(order by day) < 0
              and lag(temperature,2) over(order by day) < 0
        then 'Y'
        end as flag
    from weather) x
where x.flag = 'Y';