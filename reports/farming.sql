COPY (select * FROM v_farming WHERE activity_date >= '$FROM_DATE' and activity_date <= '$TO_DATE' ORDER BY user_name, activity_date) TO STDOUT WITH CSV HEADER;
