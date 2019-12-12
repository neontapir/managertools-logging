# frozen_string_literal: true

require './lib/employee'
require './lib/employee_folder'
require './lib/log_file'
require './lib/commands/team_meeting_command'
require_relative 'file_contents_validation_helper'

RSpec.describe TeamMeetingCommand do
  include FileContentsValidationHelper

  # force interactive mode, avoid reading global variables
  module Diary
    undef :template? if method_defined? :template?
    def template?
      false
    end
  end

  subject do
    TeamMeetingCommand.new
  end

  context 'with the Avengers team' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
      FileUtils.mkdir_p 'data/avengers/steve-rogers'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    let (:tony) { Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark') }
    let (:steve) { Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers') }
    let (:members) { [ tony, steve ]}

    it 'will append the entry to all team members' do
      members.each do |m|
        LogFile.new(EmployeeFolder.new(m))
      end

      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        subject.command ['avengers']
      end

      expected = ["  Steve Rogers, Tony Stark\n", "  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, members)
    end
  end

  context 'with multiple teams' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
      FileUtils.mkdir_p 'data/avengers/steve-rogers'
      FileUtils.mkdir_p 'data/justice-league/diana-prince'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
      FileUtils.rm_r 'data/justice-league'
    end

    it 'will append the entry to each team\'s members' do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
      diana = Employee.new(team: 'Justice League', first: 'Diana', last: 'Prince')
      members = [tony, steve, diana]

      members.each do |m|
        LogFile.new(EmployeeFolder.new(m))
      end

      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        subject.command %w[avengers justice]
      end

      expected = ["  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, members)
    end
  end
end
