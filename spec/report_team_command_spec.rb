# frozen_string_literal: true

require './lib/commands/new_hire_command'
require './lib/commands/record_diary_entry_command'
require './lib/commands/report_team_command'

RSpec.describe ReportTeamCommand do
  context 'with an existing team (Shield)' do
    shield_folder = File.join %W[#{Settings.root} shield]

    file_prefix = 'team-shield-report'

    before :context do
      expect(Dir).not_to exist shield_folder
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        expect { NewHireCommand.new.command(%w[Shield Nick Fury]) }.to output.to_stdout
        RecordDiaryEntryCommand.new.command :one_on_one, ['nick']
        ReportTeamCommand.new.command('shield', OpenStruct.new(no_launch: true))
      end
    end

    after :context do
      FileUtils.rm_r shield_folder
      FileUtils.rm ["#{file_prefix}.adoc", "#{file_prefix}.html"]
    end

    shared_examples 'report file contents matching' do |filename, *examples|
      it 'can generate the report file' do
        expect(File).to exist filename
      end

      it 'file has the expected content' do
        contents = File.read(filename)
        examples.each do |example|
          expect(contents).to match example
        end
      end
    end

    include_examples 'report file contents matching', "#{file_prefix}.adoc", /Team Shield/, /include.*overview/
    include_examples 'report file contents matching', "#{file_prefix}.html", /Team: Shield/, /Nick Fury/
  end
end
