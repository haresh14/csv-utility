#!/bin/bash

cat scoping.csv | ../csv_processor.rb \
                       -t project_start:date \
                       --row-template  row.erb --header-template header.erb --footer-template footer.erb 

