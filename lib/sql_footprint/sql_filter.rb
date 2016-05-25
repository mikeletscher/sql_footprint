module SqlFootprint
  class SqlFilter
    EXCLUDE_REGEXS = [
      /\ASHOW\s/,
      /FROM\s+pg_/,
    ].freeze

    def capture? sql
      EXCLUDE_REGEXS.none? { |regex| regex =~ sql }
    end
  end
end
