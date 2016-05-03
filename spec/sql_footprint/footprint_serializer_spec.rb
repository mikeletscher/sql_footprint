require 'spec_helper'

RSpec.describe SqlFootprint::FootprintSerializer do
  describe '#to_s' do
    let(:sql_statements) { SqlFootprint::SqlStatements.new }
    let(:statements) do
      Array.new(3) { SecureRandom.hex }
    end

    before do
      statements.each do |statement|
        sql_statements.add statement
      end
    end

    it 'sorts and joins the statements into a string' do
      expect(described_class.new(sql_statements).to_s).to eq(statements.sort.join("\n") + "\n")
    end
  end
end
