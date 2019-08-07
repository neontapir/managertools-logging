# frozen_string_literal: true

Dir.glob('./lib/entries/*_entry', &method(:require))
require './lib/employee'
require './lib/employee_folder'
require './lib/log_file'
require './lib/commands/record_diary_entry_command'
require './lib/settings'
require_relative 'file_contents_validation_helper'

RSpec.describe RecordDiaryEntryCommand do
  include FileContentsValidationHelper

  context 'with a single person' do
    before(:each) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
    end

    after(:each) do
      FileUtils.rm_r 'data/avengers'
    end

    let (:tony) { Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark') }

    subject { RecordDiaryEntryCommand.new }

    it 'can write an arbitrary entry try (one-on-one)' do
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        subject.command :one_on_one, ['tony']
      end

      expected = ["  here\n", "  Met about goals\n", "  none\n"]
      verify_answers_propagated(expected, [tony])
    end

    it 'can write a second entry type with the same method (feedback entry)' do
      Settings.with_mock_input "\nnegative\nDid a bad thing\n" do
        subject.command(:feedback, ['tony'])
      end

      expected = ["  negative\n", "  Did a bad thing\n"]
      verify_answers_propagated(expected, [tony])
    end

    it 'can write a goal entry' do
      Settings.with_mock_input "\ntoday\nBe a good citizen\n" do
        subject.command(:goal, ['tony'])
      end

      expected = ["  Be a good citizen\n"]
      verify_answers_propagated(expected, [tony])
    end

    it 'can write a performance checkpoint entry' do
      Settings.with_mock_input "\nOn track\n" do
        subject.command(:performance_checkpoint, ['tony'])
      end

      expected = ["  On track\n"]
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