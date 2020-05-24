=begin
  cat scoping.csv | ruby csv_processor.rb --row-template 'row-template.erb'
  cat scoping.csv | ruby csv_processor.rb --row-template 'row-template.erb' --csv-header 'contact_id,opportunity_id,contact_created,opportunity_created,project_start,farming,first_name,last_name,company,opportunity,scope,project'
  cat scoping.csv | ruby csv_processor.rb --row-template 'row-template.erb' --header-template 'header-template.erb' --footer-template 'footer-template.erb' -t 'contact_id:integer' -t 'opportunity_id:integer' -t 'project_start:date' -t 'scope:integer' -t 'project:float'

  cat scoping.csv | ruby csv_processor.rb --row-template '<tr>
            <td><%= csvRow["company"] %></td>
            <td><a href="https://tt.oneit.com.au/crm/editContact.jsp?contact_id=<%= csvRow["contact_id"] %>"><%= csvRow["first_name"] %> <%= csvRow["last_name"] %><a/></td>
            <td><%= csvRow["opportunity"] %></td>
            <td><%= format_pg_date(csvRow["project_start"], "%d-%m-%Y") %></td>
            <td><%= format_number(csvRow["scope"], "%.2f") %></td>
            <td><%= format_number(csvRow["project"], "%.0f") %></td>
  </tr>'

  cat scoping.csv | ruby csv_processor.rb --csv-header 'contact_id,opportunity_id,contact_created,opportunity_created,project_start,farming,first_name,last_name,company,opportunity,scope,project' --row-template '<tr>
              <td><%= csvRow["company"] %></td>
              <td><a href="https://tt.oneit.com.au/crm/editContact.jsp?contact_id=<%= csvRow["contact_id"] %>"><%= csvRow["first_name"] %> <%= csvRow["last_name"] %><a/></td>
              <td><%= csvRow["opportunity"] %></td>
              <td><%= format_pg_date(csvRow["project_start"], "%d-%m-%Y") %></td>
              <td><%= format_number(csvRow["scope"], "%.2f") %></td>
              <td><%= format_number(csvRow["project"], "%.0f") %></td>
  </tr>'
=end

require 'erb'
require 'csv'
require_relative 'option_parser'
require_relative 'column_values'

class Generator
  include ERB::Util
  attr_accessor :data, :csvHeaders, :csvRow;

  def to_s(template)
    @erb = ERB.new(template, 0, '>')
    @erb.result(binding)
  end

  def format_pg_date(val, format)
    if val == nil
      return val
    end

    if format == nil
      format = '%d-%m-%Y'
    end

    return val.strftime(format)
  end

  def format_number(val, format)
    if val == nil
      return val
    end

    if format == nil
      format = '%.02d'
    end

    return format % val
  end

  def column(columnName)
    values = []

    (1...data.length).each do |i|
      values << data[i][columnName]
    end

    return ColumnValues.new(values)
  end

  def format_value(value, type, format)
    case type
    when 'number'
      return format_number(value, format)
    when 'date'
      return format_pg_date(value, format)
    else
      raise 'Invalid format: ' + type + ':' + (format != nil ? format : '')
    end
  end

  def self.read_content_or_file (contentOrFile)
    return File.read(contentOrFile) rescue contentOrFile
  end

  def self.read_csv_file
    if ARGF.filename != "-" or (not STDIN.tty? and not STDIN.closed?)
      return ARGF.read
    else
      puts "CSV file not provided, Please provide the CSV file. E.g. cat scoping.csv | ruby csv_processor.rb"
      exit
    end
  end

  def self.generate_content(headers, data, rowTemplate, headerTemplate, footerTemplate, formats)
    generator = Generator.new()
    generator.data = data
    generator.csvHeaders = headers
    content = ''

    if headerTemplate != nil
      content << "\n" << generator.to_s(headerTemplate)
    end

    (0...data.length).each do |i|
      generator.csvRow = data[i]
      content << "\n" << generator.to_s(rowTemplate)
    end

    if footerTemplate != nil
      content << "\n" << generator.to_s(footerTemplate)
    end

    return content
  end

  def self.get_format_object(types)
    if types == nil || types.length == 0
      return {}
    end

    typesObj = {}

    types.each do |type|
      strs = type.split(':')
      typesObj[strs[0]] = strs[1]
    end

    return typesObj
  end

  def self.generate_data(headers, rowData, formats)
    csvRowData = []

    (0...rowData.length).each do |i|
      row = {}

      (0...headers.length).each do |j|
        columnName = headers[j]
        format = formats[columnName]

        if format === 'date'
          row[columnName] = rowData[i][j] != nil ? DateTime.parse(rowData[i][j]) : nil
        elsif format === 'integer'
          row[columnName] = rowData[i][j].to_i
        elsif format === 'float'
          row[columnName] = rowData[i][j].to_f
        else
          row[columnName] = rowData[i][j]
        end
      end

      csvRowData[i] = row
    end

    return csvRowData
  end
end


# Reading program argument
options = Parser.parse ARGV
#puts '############ OPTIONS ############'
#puts options
#puts '############ OPTIONS ############'
header = options[:csvHeader]
headerTemplate = Generator.read_content_or_file options[:headerTemplate]
rowTemplate = Generator.read_content_or_file options[:rowTemplate]
footerTemplate = Generator.read_content_or_file options[:footerTemplate]
formats = Generator.get_format_object options[:type]

# Removing element from ARGV so ARGF wont process it
(0..ARGV.length).each do |i|
  ARGV.pop
end

# Reading content that is piped from previous command i.e. data file of type JSON or XML
data = CSV.parse(Generator.read_csv_file, headers: false)
header = header == nil ? data[0] : header.split(',')
data = data.drop(1) # Removing header row from data
data = Generator.generate_data(header, data, formats) # structuring/casting data
puts Generator.generate_content(header, data, rowTemplate, headerTemplate, footerTemplate, formats)
