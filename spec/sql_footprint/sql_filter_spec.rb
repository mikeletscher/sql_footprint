require 'spec_helper'

describe SqlFootprint::SqlFilter do
  let(:filter) { described_class.new }

  it 'filters out SHOW queries' do
    query = "SHOW #{SecureRandom.uuid}"
    expect(filter.capture?(query)).to be_falsey
  end

  it 'filters out internal pg_*tables' do
    query = <<-EOSQL
      SELECT COUNT(*)
      FROM pg_class c
      LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relkind in ('v','r')
      AND c.relname = 'value-redacted'
      AND n.nspname = ANY (current_schemas(false))
    EOSQL
    expect(filter.capture?(query)).to be_falsey
  end

  %w(SELECT INSERT UPDATE DELETE).each do |prefix|
    it "does not filter #{prefix} queries" do
      query = "#{prefix} #{SecureRandom.uuid}"
      expect(filter.capture?(query)).to be_truthy
    end
  end
end
