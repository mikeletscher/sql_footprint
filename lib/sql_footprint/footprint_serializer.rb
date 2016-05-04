module SqlFootprint
  class FootprintSerializer
    NEWLINE = "\n".freeze

    def initialize statements
      @statements = statements
    end

    def to_s
      @statements.sort.join(NEWLINE) + NEWLINE
    end
  end
end
