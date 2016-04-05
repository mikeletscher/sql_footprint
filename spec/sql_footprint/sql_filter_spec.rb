require 'spec_helper'

describe SqlFootprint::SqlFilter do
  let(:filter) { described_class.new }

  it 'filters out SHOW queries' do
    query = "SHOW #{SecureRandom.uuid}"
    expect(filter.capture?(query)).to be_falsey
  end

  %w(SELECT INSERT UPDATE DELETE).each do |prefix|
    it "does not filter #{prefix} queries" do
      query = "#{prefix} #{SecureRandom.uuid}"
      expect(filter.capture?(query)).to be_truthy
    end
  end
end
