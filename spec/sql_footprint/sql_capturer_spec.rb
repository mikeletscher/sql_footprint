require 'spec_helper'

describe SqlFootprint::SqlCapturer do
  let(:db_name) { SecureRandom.uuid }
  let(:serialized_statements) { SecureRandom.uuid }
  describe '#initialize' do
    it 'requires db_name' do
      expect { described_class.new }.to raise_error ArgumentError
    end

    it 'sets the database_name' do
      described_class.new(db_name).tap do |capturer|
        expect(capturer.database_name).to eq db_name
      end
    end
  end

  before do
    allow(SqlFootprint::SqlFilter).to receive(:new).and_return(sql_filter_double)
    allow(SqlFootprint::SqlAnonymizer).to receive(:new).and_return(sql_anonymizer_double)
    allow(SqlFootprint::SqlStatements).to receive(:new).and_return(sql_statements_double)
    allow(SqlFootprint::FootprintSerializer).to receive(:new).with(sql_statements_double)
      .and_return(footprint_serializer_double)
  end

  let(:sql_filter_double) do
    double('SqlFilter').tap do |d|
      allow(d).to receive(:capture?).with(sql).and_return(should_capture)
    end
  end
  let(:sql_anonymizer_double) do
    double('SqlAnonymizer').tap do |d|
      allow(d).to receive(:anonymize).with(sql).and_return(anonymized_sql)
    end
  end
  let(:sql_statements_double) do
    double('SqlStatements')
  end
  let(:footprint_serializer_double) do
    double('SqlStatementsSearializer').tap do |d|
      allow(d).to receive(:to_s).and_return(serialized_statements)
    end
  end

  let(:sql) { SecureRandom.uuid }
  let(:anonymized_sql) { SecureRandom.uuid }
  let(:should_capture) { true }

  describe '#capture' do
    subject { described_class.new(db_name) }

    context 'when the SqlFilter returns false' do
      let(:should_capture) { false }

      it 'does not add the statement' do
        expect(sql_statements_double).not_to receive(:add)
        subject.capture(sql)
      end
    end

    context 'when the SqlFilter returns true' do
      let(:should_capture) { true }

      it 'does add the statement' do
        expect(sql_statements_double).to receive(:add).with(anonymized_sql)
        subject.capture(sql)
      end
    end
  end

  describe '#write' do
    subject { described_class.new(db_name) }

    it 'writes the serialized statements to the contents of a file' do
      expect(footprint_serializer_double).to receive(:to_s)
        .and_return(serialized_statements)
      expect(File).to receive(:write).with(anything, serialized_statements)
      subject.write
    end

    it 'writes to db-specific filename' do
      expect(File).to receive(:write).with("db/footprint.#{db_name}.sql", anything)
      subject.write
    end
  end
end
