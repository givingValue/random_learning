# Problem Description:
# Write a SQL query to fetch all the duplicate records from a table.

# Tables Structure:
drop table if exists users;

create table users (
    user_id int primary key,
    user_name varchar(30) not null,
    email varchar(50)
);

insert into users values
(1, 'Sumit', 'sumit@gmail.com'),
(2, 'Reshma', 'reshma@gmail.com'),
(3, 'Farhana', 'farhana@gmail.com'),
(4, 'Robin', 'robin@gmail.com'),
(6, 'Robin', 'robin@gmail.com');

select * from users;

# Solution 1 (Personal Solution):
SELECT user_name, email
FROM users
GROUP BY user_name, email
HAVING count(*) > 1;

# Solution 2 (Not Personal Solution):
select *
from users AS u
where u.user_id not in (
    select min(user_id) as ctid
    from users
    group by user_name
    order by ctid
);

# Solution 3 (Not Personal Solution):
select user_id, user_name, email
from (
    select *,
    row_number() over (partition by user_name order by user_id) as rn
    from users u
    order by user_id) x
where x.rn <> 1;

# Solution 4 (Personal Solution):
select user_id, user_name, email
from (
    select *,
    lead(user_id) over (partition by user_name order by user_id) as lead_user,
    count(user_id) over (partition by user_name) as user_count
    from users u
    order by user_id
) x
where x.lead_user IS NULL
    AND x.user_count > 1;