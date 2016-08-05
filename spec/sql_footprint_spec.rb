require 'spec_helper'

describe SqlFootprint do
  it 'has a version number' do
    expect(SqlFootprint::VERSION).not_to be nil
  end

  let(:statements) { described_class.capturers[':memory:'].statements }
  let(:footprint_file_name) { './db/footprint.:memory:.sql' }

  describe '.start' do
    before do
      described_class.start

      # Warmup so Widget.create just makes one new flavor of SQL
      Widget.first
      Cog.create!
    end

    it 'logs sql' do
      expect { Widget.create! }.to change { statements.count }.by(+1)
    end

    it 'formats inserts' do
      Widget.create!
      expect(statements.to_a).to include(
        'INSERT INTO "widgets" ("created_at", "updated_at") VALUES (values-redacted)'
      )
    end

    it 'formats selects' do
      Widget.where(name: SecureRandom.uuid, quantity: 1).last
      expect(statements.to_a).to include(
        'SELECT  "widgets".* FROM "widgets" ' \
        'WHERE "widgets"."name" = ? AND ' \
        '"widgets"."quantity" = ? ' \
        'ORDER BY "widgets"."id" DESC LIMIT ?'
      )
    end

    it 'dedupes the same sql' do
      expect do
        Widget.create!
        Widget.create!
      end.to change { statements.count }.by(+1)
    end

    it 'works with joins' do
      Widget.joins(:cogs).where(name: SecureRandom.uuid).load
      expect(statements.to_a).to include(
        'SELECT "widgets".* FROM "widgets" ' \
        'INNER JOIN "cogs" ON "cogs"."widget_id" = "widgets"."id" ' \
        'WHERE "widgets"."name" = ?'
      )
    end

    it 'can exclude some statements' do
      expect do
        Widget.where(name: SecureRandom.hex).last
        widget = described_class.exclude { Widget.create! }
        expect(widget).to be_a(Widget)
      end.to change { statements.count }.by(+1)
      expect(statements.to_a.join).not_to include 'INSERT INTO \"widgets\"'
    end

    it 'does not write SHOW queries' do
      begin
        Widget.connection.execute("SHOW #{SecureRandom.uuid}")
      rescue
        "We don't care about the validity of the SQL" # rubocop
      end
      expect(statements.to_a.join).not_to include 'SHOW'
    end
  end

  describe '.stop' do
    it 'writes the footprint' do
      described_class.start
      Widget.create!
      described_class.stop
      log = File.read(footprint_file_name)
      expect(log).to include('INSERT INTO')
    end

    it 'writes the sorted statements' do
      described_class.start
      Widget.create!
      Widget.first
      described_class.stop
      log = File.read(footprint_file_name)
      expect(statements.sort).to eq(log.split("\n").sort)
    end

    it 'removes old results' do
      described_class.start
      Widget.create!
      described_class.stop
      described_class.start
      Widget.last
      described_class.stop
      log = File.read(footprint_file_name)
      expect(log).not_to include('INSERT INTO')
    end
  end
end
