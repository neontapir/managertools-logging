# frozen_string_literal: true

require './lib/commands/new_hire_command'
require './lib/commands/record_diary_entry_command'
require './lib/commands/report_command'

RSpec.describe ReportCommand do
  context 'with an existing employee' do
    avengers_folder = File.join(%W[#{Settings.root} avengers])
    file_prefix = 'report-tony-stark'
    report_files = ["#{file_prefix}.adoc", "#{file_prefix}.html"]

    before :all do
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        expect{ NewHireCommand.new.command(%w[Avengers Tony Stark]) }.to output.to_stdout
        RecordDiaryEntryCommand.new.command :one_on_one, ['tony']
        ReportCommand.new.command('tony', OpenStruct.new(no_launch: true))
      end
    end

    after :all do
      FileUtils.rm_r avengers_folder
      FileUtils.rm report_files
    end

    it 'can generate a report' do
      report_files.each do |file|
        expect(File).to exist file
      end
    end

    it 'report specification file has the expected content' do
      spec_file = File.read("#{file_prefix}.adoc")
      expect(spec_file).to match /include.*overview/
      expect(spec_file).to match /include.*log/
    end

    it 'report output file has the expected content' do
      report_file = File.read("#{file_prefix}.html")
      expect(report_file).to match /Met about goals/
    end
  end
end
