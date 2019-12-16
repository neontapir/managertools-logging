# frozen_string_literal: true

require './lib/commands/new_hire_command'
require './lib/commands/record_diary_entry_command'
require './lib/commands/report_command'

RSpec.describe ReportCommand do
  context 'with an existing employee' do
    before(:all) do
      # FileUtils.mkdir_p 'data/avengers/tony-stark'
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        expect{ NewHireCommand.new.command(%w[Avengers Tony Stark]) }.to output.to_stdout
        RecordDiaryEntryCommand.new.command :one_on_one, ['tony']
        ReportCommand.new.command('tony', OpenStruct.new(no_launch: true))
      end
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
      FileUtils.rm ['report-tony-stark.adoc', 'report-tony-stark.html']
    end

    it 'can generate a report' do
      expect(File.exist? 'report-tony-stark.adoc').to be_truthy
      expect(File.exist? 'report-tony-stark.html').to be_truthy
    end

    it 'report specification file has the expected content' do
      spec_file = File.read('report-tony-stark.adoc')
      expect(spec_file).to match /include.*overview/
      expect(spec_file).to match /include.*log/
    end

    it 'report output file has the expected content' do
      report_file = File.read('report-tony-stark.html')
      expect(report_file).to match /Met about goals/
    end
  end
end
