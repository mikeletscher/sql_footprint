require 'spec_helper'

describe SqlFootprint do
  it 'has a version number' do
    expect(SqlFootprint::VERSION).not_to be nil
  end

  describe '.start' do
    let!(:logger) { described_class.start }
    let(:sql) { logger.logs.last }

    it 'logs sql' do
      Widget.create!
      expect(logger.logs.length).to eq 1
    end

    it 'formats inserts' do
      Widget.create!
      expect(sql).to eq 'INSERT INTO "widgets" ("created_at", "updated_at") VALUES (?, ?)'
    end

    it 'formats selects' do
      Widget.where(name: SecureRandom.uuid, quantity: 1).last
      expect(sql).to eq 'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" = '\
        "'value-redacted' AND \"widgets\".\"quantity\" = number-redacted ORDER BY \"widgets"\
        '"."id" DESC LIMIT 1'
    end

    it 'formats IN clauses' do
      Widget.where(name: [SecureRandom.uuid, SecureRandom.uuid]).last
      expect(sql).to eq 'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" '\
        'IN (values-redacted) ORDER BY "widgets"."id" DESC LIMIT 1'
    end

    it 'dedupes the same sql' do
      Widget.create!
      Widget.create!
      expect(logger.logs.length).to eq 1
    end

    it 'sorts the results' do
      Widget.where(name: SecureRandom.uuid, quantity: 1).last
      Widget.create!
      expect(logger.logs.first).to include('INSERT INTO')
    end

    it 'works with joins' do
      Widget.joins(:cogs).where(name: SecureRandom.uuid).load
      expected = 'SELECT "widgets".* FROM "widgets" INNER JOIN "'\
        'cogs" ON "cogs"."widget_id" = "widgets"."id" WHERE '\
        "\"widgets\".\"name\" = 'value-redacted'"
      expect(logger.logs.first).to eq expected
    end

    it 'can exclude some statements' do
      Widget.where(name: SecureRandom.uuid).last
      widget = described_class.exclude { Widget.create! }
      expect(widget).to be_a(Widget)
      expect(logger.logs.length).to eq 1
      expect(logger.logs.first).to start_with('SELECT')
    end
  end

  describe '.stop' do
    it 'writes the footprint' do
      described_class.start
      Widget.create!
      described_class.stop
      log = File.read('footprint.sql')
      expect(log).to include('INSERT INTO')
    end

    it 'removes old results' do
      described_class.start
      Widget.create!
      described_class.stop
      described_class.start
      Widget.last
      described_class.stop
      log = File.read('footprint.sql')
      expect(log).not_to include('INSERT INTO')
    end
  end
end
