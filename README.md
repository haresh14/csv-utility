# csv-utility
Ruby utility to convert csv file data to html or any other format.  It can be used for quickly writing reports or transforming csv to another format.

### What it does
The utility is designed as something like `awk`, `jq`, or `xsltproc` but for CSV files.

It ingests a CSV and processes an ERB template line by line to produce a text output.  This output could be CSV, XML, JSON, or HTML or any other type of textual format.

 1. Read the headers from the first line of the CSV (default) or supply them directly (`-c` / `--csv-header`)
 2. Supply an ERB template for each row either as a string or as a file name (`-r` / `--row-template`).  The variable `csvRow` is a map containing a key per column in the CSV.
 3. Supply an ERB template for a header (`--header-template`) or footer (`-f` / `--footer-template`) as either a string or a file.  The variable `data` is a list of rows. 
 4. In the header / footer you may call `col(colname)` to return a list of values in that column of the CSV
 5. You can parse all values in a column via `-t colname:type` where type can be `date`, `integer`, or `float`.  You can parse multiple columns using `-t cola:type -t colb:type`

### Simplest Usage
This takes a CSV and reads it in.  It assumes that the column headers are the first row of the CSV.  The row ERB is defined inline and produces a basic json.
```
cat some.csv | csv_processor.rb -r '{ a:<%= csvRow["fieldA"] %>, b: <%= csvRow["fieldB"] %>} '
```
### Complex Usage
This has a header and footer as well as a row template.  All are defined in files.
```
cat some.csv | csv_processor.rb --row-template row.erb --header-template header.erb --footer-template footer.erb
```
### Parsing Values
The `-t col:format` will parse the values and place the typed value in `data` and `csvRow` for processing.

Without -t, your columns are treated as string.
### CSVs Without Headers
You can pass `--csv-header` to list out a csv of header columns e.g. `--csv-header a,b,c` and then use those to refer to the columns in your ERB e.g. `<%= csvRow['a'] %>`

### Examples
There is a simple example in the examples folder.  It uses a hardcoded csv to generate a simple report.

There are also 2 examples in the reports folder.  Each one contains a row / header / footer template, an example SQL file for postgres and a driver bash script.

### Ruby Hacks
For all the non-ruby people :-)

Take a column and sum up all the values, then format to 2 dp.
```
<%= '%.2f' % col('hrs_a').reduce(:+) %>
```
Take a column and count all the positive values:
```
<%= col('hrs_d').select {|hrs| hrs > 0 }.length() %>
```

