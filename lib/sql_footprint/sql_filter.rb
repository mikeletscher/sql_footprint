module SqlFootprint
  class SqlFilter
    EXCLUDE_REGEXS = [
      /^SHOW .*$/
    ].freeze

    def capture? sql
      EXCLUDE_REGEXS.none? { |regex| regex =~ sql }
    end
  end
end
