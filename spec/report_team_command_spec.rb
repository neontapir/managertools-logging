# frozen_string_literal: true

require './lib/commands/new_hire_command'
require './lib/commands/record_diary_entry_command'
require './lib/commands/report_team_command'

RSpec.describe ReportTeamCommand do
  context 'with an existing team' do
    avengers_folder = File.join(%W[#{Settings.root} avengers])

    file_prefix = 'team-avengers-report'

    before(:all) do
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        expect{ NewHireCommand.new.command(%w[Avengers Tony Stark]) }.to output.to_stdout
        RecordDiaryEntryCommand.new.command :one_on_one, ['tony']
        ReportTeamCommand.new.command('avengers', OpenStruct.new(no_launch: true))
      end
    end

    after(:all) do
      FileUtils.rm_r avengers_folder
      FileUtils.rm ["#{file_prefix}.adoc", "#{file_prefix}.html"]
    end

    it 'can generate a report' do
      expect(File.exist? "#{file_prefix}.adoc").to be_truthy
      expect(File.exist? "#{file_prefix}.html").to be_truthy
    end

    it 'report specification file has the expected content' do
      spec_file = File.read("#{file_prefix}.adoc")
      expect(spec_file).to match /Team Avengers/
      expect(spec_file).to match /include.*overview/
    end

    it 'report output file has the expected content' do
      report_file = File.read("#{file_prefix}.html")
      expect(report_file).to match /Team: Avengers/
      expect(report_file).to match /Tony Stark/
    end
  end
end