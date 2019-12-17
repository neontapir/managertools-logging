# frozen_string_literal: true

require './lib/employee'
require './lib/log_file'
require './lib/commands/last_entry_command'
require './lib/entries/observation_entry'

RSpec.describe LogFile do
  context 'with diary entries' do
    iron_man_folder = File.join(%W[#{Settings.root} avengers tony-stark])

    before(:all) do
      FileUtils.mkdir_p iron_man_folder
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      log_file = LogFile.new(EmployeeFolder.new(tony))
      log_file.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      log_file.append ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
    end

    after(:all) do
      FileUtils.rm_r File.dirname(iron_man_folder)
    end

    subject do
      LastEntryCommand.new
    end

    it 'displays the last entry correctly' do
      expect($stdout).to receive(:puts).with("=== Observation (February  4, 2001,  5:06 AM)\nContent::\n  Observation B\n")
      subject.command 'stark'
    end
  end
end
