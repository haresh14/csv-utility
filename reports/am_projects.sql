-- A Postgres script designed to be piped through envsubst to set from/to date.
COPY (

SELECT company_name, 
       string_agg(DISTINCT project_name, ', ') projects, 
       string_agg(DISTINCT user_name, ', ') users, 
       SUM((CASE WHEN user_name = 'a' THEN hours ELSE 0 END)) hrs_a, 
       SUM((CASE WHEN user_name = 'b' THEN hours ELSE 0 END)) hrs_b, 
       SUM((CASE WHEN user_name = 'c' THEN hours ELSE 0 END)) hrs_c, 
       SUM((CASE WHEN user_name = 'd' THEN hours ELSE 0 END)) hrs_d, 
       SUM(hours) hrs      
FROM am_projects ('${FROM_DATE}', '${TO_DATE}') 
GROUP BY company_name
ORDER BY company_name

) TO STDOUT WITH CSV HEADER;
