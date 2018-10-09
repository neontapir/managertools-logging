# frozen_string_literal: true

require './lib/log_file.rb'
require './lib/last_entry_command.rb'
require './lib/observation_entry.rb'

describe LogFile, order: :defined do
  context 'with diary entries' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      log_file = LogFile.new(EmployeeFolder.new(tony))
      log_file.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      log_file.append ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    subject do
      LastEntryCommand.new
    end

    it 'displays the last entry correctly' do
      expect(STDOUT).to receive(:puts).with("=== Observation (February  4, 2001,  5:06 AM)\nContent::\n  Observation B\n")
      subject.command 'stark'
    end
  end
end
