#!/bin/bash
# This report imports postgres dates and formats them.
# Also it produces alt text in the HTML output.

cat reports/farming.sql | envsubst | psql -U postgres -h localhost david1it > /tmp/farming.csv
cat /tmp/farming.csv | /root/csv-utility/csv_processor.rb \
                       -t activity_date:date
                       --row-template  reports/farming-row.erb --header-template reports/farming-header.erb --footer-template reports/farming-footer.erb \
                       > /tmp/farming.html

