require 'sql_footprint/version'
require 'sql_footprint/sql_anonymizer'
require 'sql_footprint/sql_filter'
require 'sql_footprint/sql_statements'
require 'active_support/notifications'

module SqlFootprint
  FILENAME = 'footprint.sql'.freeze
  NEWLINE = "\n".freeze

  ActiveSupport::Notifications.subscribe('sql.active_record') do |_, _, _, _, payload|
    capture payload.fetch(:sql)
  end

  class << self
    attr_reader :statements

    def start
      @anonymizer = SqlAnonymizer.new
      @filter     = SqlFilter.new
      @capture    = true
      @statements = SqlStatements.new
    end

    def stop
      @capture = false
      File.write FILENAME, statements.sort.join(NEWLINE) + NEWLINE
    end

    def exclude
      @capture = false
      yield
    ensure
      @capture = true
    end

    def capture sql
      return unless @capture && @filter.capture?(sql)
      @statements.add @anonymizer.anonymize(sql)
    end
  end
end
