require 'sql_footprint/version'
require 'sql_footprint/sql_anonymizer'
require 'set'
require 'active_support/notifications'

module SqlFootprint
  ActiveSupport::Notifications.subscribe('sql.active_record') do |_, _, _, _, payload|
    capture payload.fetch(:sql)
  end

  class << self
    def start
      @anonymizer = SqlAnonymizer.new
      @capture = true
      @lines   = Set.new
    end

    def stop
      @capture = false
      File.open('footprint.sql', 'w') do |f|
        lines.each do |line|
          f.puts line
        end
      end
    end

    def exclude
      @capture = false
      yield
    ensure
      @capture = true
    end

    def lines
      @lines.sort
    end

    def capture sql
      return unless @capture
      @lines << @anonymizer.anonymize(sql)
    end
  end
end
