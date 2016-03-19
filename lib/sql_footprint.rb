require 'sql_footprint/version'

module SqlFootprint
  def self.start
    @original_logger = ActiveRecord::Base.logger
    @logger = Logger.new
    ActiveRecord::Base.logger = @logger
  end

  def self.stop
    ActiveRecord::Base.logger = @original_logger
    File.open('footprint.sql', 'w') do |f|
      @logger.logs.each do |log|
        f.puts log
      end
    end
  end

  class Logger
    def initialize
      @logs = []
    end

    attr_reader :logs

    def error param
      raise param
    end

    def debug text
      if sql? text
        sql = format_sql(text)
        logs << sql unless logs.include?(sql)
        logs.sort!
      end
    end

    def debug?
      true
    end

    private

    def sql? text
      /SQL/.match(text) ||
        /Load\s\(/.match(text)
    end

    def format_sql text
      strip_values(text).split("\e\[0m")
                        .select { |t| !t.include?('SQL') }
                        .find { |t| !/Load\s\(/.match(t) }
                        .gsub(/\e\[1m/, '')
                        .strip
    end

    def strip_values text
      text = text.gsub(/\[\[.*\]\]/, '')
      text = strip_string_values(text)
      text = strip_integer_values(text)
      strip_in_clause_values(text)
    end

    def strip_in_clause_values text
      text.gsub(/\sIN\s\((.*)\)/) do |_match|
        ' IN (values-redacted)'
      end
    end

    def strip_integer_values text
      text.gsub(/\s\=\s([0-9]+)/) do |_match|
        ' = number-redacted'
      end
    end

    def strip_string_values text
      text.gsub(/\s\=\s\'(.*)\'/) do |_match|
        " = 'value-redacted'"
      end
    end
  end
end
