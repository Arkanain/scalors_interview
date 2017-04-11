require 'csv'
require 'date'
require File.expand_path('../lib/modifier', File.dirname(__FILE__))

class Modifying
  class << self
    def latest(name)
      directory = "#{ENV['HOME']}/workspace"
      files = Dir["#{directory}/*#{name}*.txt"]

      files.sort_by! { |file|
        last_date = /\d+-\d+-\d+_[[:alpha:]]+\.txt$/.match(file)
        last_date = "#{last_date}".match(/\d+-\d+-\d+/)

        DateTime.parse("#{last_date}")
      }

      raise RuntimeError, "Directory #{directory} is empty." if files.empty?

      files.last
    end

    def execute
      modified = input = latest('project_2012-07-27_2012-10-10_performancedata')
      modification_factor = 1
      cancellaction_factor = 0.4
      modifier = Modifier.new(modification_factor, cancellaction_factor)
      modifier.modify(modified, input)

      puts 'DONE modifying'
    end
  end
end
