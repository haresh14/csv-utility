require 'optparse'

class Parser
  def self.parse(options)
    parsedArgs = {
        type: []
    }

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: cat scoping.csv | csv_processor.rb [options]"

      opts.on("-c", "--csv-header CSVHEADERS", "Column headers by comma separated values. This is REQUIRED parameter.") do |n|
        parsedArgs[:csvHeader] = n
      end

      opts.on("-r", "--row-template TEMPLATE", "Template of the row. This is REQUIRED parameter. You can directly pass the template as string or template file path.") do |n|
        parsedArgs[:rowTemplate] = n
      end

      opts.on("-h", "--header-template TEMPLATE", "Template of the header. You can directly pass the template as string or template file path.") do |n|
        parsedArgs[:headerTemplate] = n
      end

      opts.on("-f", "--footer-template TEMPLATE", "Template of the footer. You can directly pass the template as string or template file path.") do |n|
        parsedArgs[:footerTemplate] = n
      end

      opts.on("-t", "--type TYPE", "Type of the column") do |n|
        parsedArgs[:type] << n
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(options)
    parsedArgsValues = parsedArgs.to_h

    if parsedArgsValues[:rowTemplate] == nil
      puts 'Please specify row template. For more help , Please run: ruby csv_processor.rb --help'
      exit
    end

    return parsedArgsValues
  end
end

#options = Parser.parse ARGV
#puts options
#puts options[:csvHeader]