Dir.glob('./lib/*_entry.rb', &method(:require))
require_relative 'multiple_member_spec_helper'
require './lib/employee.rb'
require './lib/employee_folder.rb'
require './lib/log_file.rb'
require './lib/record_diary_entry_command.rb'
require './lib/settings.rb'

describe RecordDiaryEntryCommand do
  include MultipleMemberSpecHelper

  before(:all) do
    FileUtils.mkdir_p 'data/avengers/tony-stark'
  end

  after(:all) do
    FileUtils.rm_r 'data/avengers'
  end

  let (:tony) { Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark') }

  subject do
    RecordDiaryEntryCommand.new
  end

  it 'can send an O3 command' do
    Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
      subject.command :o3, ['tony']
    end

    log_file = LogFile.new(EmployeeFolder.new(tony))

    expected = ["  here\n", "  Met about goals\n", "  none\n"]
    verify_answers_propagated(expected, [tony])
  end

  it 'can send an feedback command' do
    Settings.with_mock_input "\nnegative\nDid a bad thing\n" do
      subject.command :feedback, ['tony']
    end

    log_file = LogFile.new(EmployeeFolder.new(tony))

    expected = ["  negative\n", "  Did a bad thing\n"]
    verify_answers_propagated(expected, [tony])
  end
end