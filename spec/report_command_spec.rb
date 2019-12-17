# frozen_string_literal: true

require './lib/commands/new_hire_command'
require './lib/commands/record_diary_entry_command'
require './lib/commands/report_command'

RSpec.describe ReportCommand do
  context 'with an existing employee' do
    avengers_folder = File.join(%W[#{Settings.root} avengers])
    file_prefix = 'report-tony-stark'

    before :all do
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        expect{ NewHireCommand.new.command(%w[Avengers Tony Stark]) }.to output.to_stdout
        RecordDiaryEntryCommand.new.command :one_on_one, ['tony']
        ReportCommand.new.command('tony', OpenStruct.new(no_launch: true))
      end
    end

    after :all do
      FileUtils.rm_r avengers_folder
      FileUtils.rm ["#{file_prefix}.adoc", "#{file_prefix}.html"]
    end

    shared_examples 'file contents matching' do |filename, *examples|
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

    include_examples 'file contents matching', "#{file_prefix}.adoc", /include.*overview/,  /include.*log/
    include_examples 'file contents matching', "#{file_prefix}.html", /Met about goals/
  end
end
