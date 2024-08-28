# Problem Description:
# Find the top 2 accounts with the maximum number of unique patients on a monthly basis.
# Note: Prefer the account if with the least value in case of same number of unique patients


# Tables Structure:
drop table if exists patient_logs;

create table patient_logs (
  account_id int,
  date date,
  patient_id int
);

insert into patient_logs values (1, STR_TO_DATE('02-01-2020','%d-%m-%Y'), 100);
insert into patient_logs values (1, STR_TO_DATE('27-01-2020','%d-%m-%Y'), 200);
insert into patient_logs values (2, STR_TO_DATE('01-01-2020','%d-%m-%Y'), 300);
insert into patient_logs values (2, STR_TO_DATE('21-01-2020','%d-%m-%Y'), 400);
insert into patient_logs values (2, STR_TO_DATE('21-01-2020','%d-%m-%Y'), 300);
insert into patient_logs values (2, STR_TO_DATE('01-01-2020','%d-%m-%Y'), 500);
insert into patient_logs values (3, STR_TO_DATE('20-01-2020','%d-%m-%Y'), 400);
insert into patient_logs values (1, STR_TO_DATE('04-03-2020','%d-%m-%Y'), 500);
insert into patient_logs values (3, STR_TO_DATE('20-01-2020','%d-%m-%Y'), 450);

select * from patient_logs;

# Solution 1 (Personal Solution):
SELECT month, account_id, unique_patients
FROM (
    SELECT account_id, MONTHNAME(date) AS month,
           COUNT(DISTINCT patient_id) AS unique_patients,
           ROW_NUMBER() OVER (PARTITION BY MONTHNAME(date) ORDER BY COUNT(DISTINCT patient_id) DESC,account_id) AS account_rank
    FROM patient_logs
    GROUP BY account_id, MONTHNAME(date)
) AS ranked_data
WHERE account_rank <= 2;

# Solution 2 (Not Personal Solution):
select a.month, a.account_id, a.no_of_unique_patients
from (
    select x.month, x.account_id, no_of_unique_patients,
	    row_number() over (partition by x.month order by x.no_of_unique_patients desc) as rn
	from (
		select pl.month, pl.account_id, count(1) as no_of_unique_patients
		from (select distinct EXTRACT(MONTH FROM date) as month, account_id, patient_id from patient_logs) pl
		group by pl.month, pl.account_id) x
    ) a
where a.rn < 3;