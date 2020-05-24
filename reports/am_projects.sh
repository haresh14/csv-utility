#!/bin/bash
# This report has columns per user using a stored procedure instead of a view.
# The interesting part is the footer, where a sub and count is calculated.

export FROM_DATE=2020-04-01
export TO_DATE=2020-05-01
export DATABASE=somedb

# Normally I pipe this right through rather than using a temporary CSV
cat reports/am_projects.sql | envsubst | psql -U postgres -h localhost $DATABASE > /tmp/am_projects.csv

cat /tmp/am_projects.csv | /root/csv-utility/csv_processor.rb \
                           -t hrs_a:float -t hrs_b:float -t hrs_c:float -t hrs_d:float -t hrs:float \
                           --row-template  reports/am_projects-row.erb --header-template reports/am_projects-header.erb --footer-template reports/am_projects-footer.erb \
                           > /tmp/am_projects.hstml
                           
sendEmail -f reports@email.com.au -t dave@email.com.au  -u "AM Active Projects " $FROM_DATE to $TO_DATE -o message-content-type=html -o message-file=/tmp/am_projects.html


