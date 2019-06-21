Dir.glob('./lib/*_entry.rb', &method(:require))
require_relative 'multiple_member_spec_helper'
require './lib/employee.rb'
require './lib/employee_folder.rb'
require './lib/log_file.rb'
require './lib/record_diary_entry_command.rb'
require './lib/settings.rb'

describe RecordDiaryEntryCommand do
  include MultipleMemberSpecHelper

  context 'with a single person' do
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

    it 'can write an arbitrary entry try (one-on-one)' do
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        subject.command :o3, ['tony']
      end

      log_file = LogFile.new(EmployeeFolder.new(tony))

      expected = ["  here\n", "  Met about goals\n", "  none\n"]
      verify_answers_propagated(expected, [tony])
    end

    it 'can write a second entry type with the same method (feedback entry)' do
      Settings.with_mock_input "\nnegative\nDid a bad thing\n" do
        subject.command(:feedback, ['tony'])
      end

      log_file = LogFile.new(EmployeeFolder.new(tony))

      expected = ["  negative\n", "  Did a bad thing\n"]
      verify_answers_propagated(expected, [tony])
    end
  end

  context 'with multiple people' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers/thor-odinson'
      FileUtils.mkdir_p 'data/avengers/steve-rogers'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    let (:thor) { Employee.new(team: 'Avengers', first: 'Thor', last: 'Odinson') }
    let (:steve) { Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers') }
    subject { RecordDiaryEntryCommand.new }

    it 'will append the entry to all their logs' do
      members = [thor, steve]

      members.each do |m|
        LogFile.new(EmployeeFolder.new(m))
      end

      Settings.with_mock_input "\n\nSpoke about important things\n" do
        subject.command(:observation, %w[thor rogers])
      end

      expected = ["  Thor Odinson, Steve Rogers\n", "  Spoke about important things\n"]
      verify_answers_propagated(expected, members)
    end
  end
end