require 'set'
require 'active_support/core_ext/module/delegation'

module SqlFootprint
  class SqlStatements
    def initialize
      @statements = Set.new
    end

    delegate :to_a, :add, :sort, :count, to: :statements

    private

    attr_reader :statements
  end
end
