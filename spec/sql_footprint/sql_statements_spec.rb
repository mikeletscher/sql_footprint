require 'spec_helper'

RSpec.describe SqlFootprint::SqlStatements do

  let(:sql_statements) { described_class.new }

  describe '#to_a' do
    before do
      statements.each do |statement|
        sql_statements.add statement
      end
    end

    context 'no statements' do
      let(:statements) { [] }

      it 'returns an empty array' do
        expect(sql_statements.to_a).to eq statements
      end
    end

    context 'one statement' do
      let(:statements) { [SecureRandom.hex] }

      it 'returns an array with one statement' do
        expect(sql_statements.to_a).to eq statements
      end
    end

    context 'multiple statements' do
      let(:statements) do
        Array.new(3) { SecureRandom.hex }
      end

      it 'returns all of the statements given' do
        expect(sql_statements.to_a).to eq statements
      end
    end

  end

  describe '#add' do
    before do
      sql_statements.add statement
    end

    let(:statement) { SecureRandom.hex }

    it 'adds the sql statement to the collection' do
      expect(sql_statements.to_a).to include statement
    end
  end

  describe '#sort' do
    before do
      statements.each do |statement|
        sql_statements.add statement
      end
    end

    let(:statements) { ['b', 'c', 'a'] }

    it 'sorts the statements given' do
      expect(statements.sort).to eq ['a', 'b', 'c']
    end
  end

  describe '#count' do
    before do
      statements.each do |statement|
        sql_statements.add statement
      end
    end

    context 'no statements' do
      let(:statements) { [] }

      it 'returns 0' do
        expect(sql_statements.count).to eq 0
      end
    end

    context 'one statement' do
      let(:statements) { [SecureRandom.hex] }

      it 'returns 1' do
        expect(sql_statements.count).to eq 1
      end
    end

    context 'three statements' do
      let(:statements) do
        Array.new(3) { SecureRandom.hex }
      end

      it 'returns 3' do
        expect(sql_statements.count).to eq 3
      end
    end
  end
end
