# Problem Description:
# From the students table, write a SQL query to interchange the adjacent student names.
# Note: If there are no adjacent student then the student name should stay the same.

# Tables Structure:
drop table if exists students;

create table students (
    id int primary key,
    student_name varchar(50) not null
);

insert into students values
(1, 'James'),
(2, 'Michael'),
(3, 'George'),
(4, 'Stewart'),
(5, 'Robin');

select * from students;

# Solution 1 (Personal Solution):
SELECT *
FROM (
    SELECT *,
           CASE
               WHEN MOD(id,2) = 1 AND (LEAD(student_name) over ()) IS NOT NULL
                    THEN (LEAD(student_name) over ())
               WHEN MOD(id,2) = 0
                    THEN (LAG(student_name) over ())
               ELSE student_name
           END AS new_name
    FROM students
    ORDER BY id
) AS x;

SELECT *,
       CASE
            WHEN MOD(id,2) = 1
                THEN (LEAD(student_name, 1, student_name) over ())
            ELSE (LAG(student_name) over ())
       END AS new_name
FROM students
ORDER BY id;

# Solution 2 (Not Personal Solution):
select id,student_name,
    case
        when id%2 <> 0
            then lead(student_name,1,student_name) over(order by id)
        when id%2 = 0
            then lag(student_name) over(order by id)
    end as new_student_name
from students;