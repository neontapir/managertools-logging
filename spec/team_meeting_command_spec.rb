# frozen_string_literal: true

require 'multiple_member_spec_helper.rb'
require './lib/employee.rb'
require './lib/employee_folder.rb'
require './lib/log_file.rb'
require './lib/team_meeting_command.rb'

describe TeamMeetingCommand do
  include MultipleMemberSpecHelper

  module Diary
    undef :template? if method_defined? :template?
    def template?
      false # force interactive mode, avoid reading global variables
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

    it 'will append the entry to all team members' do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
      members = [tony, steve]

      members.each do |m|
        LogFile.new(EmployeeFolder.new(m))
      end

      Settings.with_mock_input "\nall\n\nWe met about stuff\n\n" do
        subject.command ['avengers']
      end

      expected = ["  all\n", "  unspecified\n", "  We met about stuff\n", "  none\n"]
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

    it 'will append the entry to all team members' do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
      diana = Employee.new(team: 'Justice League', first: 'Diana', last: 'Prince')
      members = [tony, steve, diana]

      members.each do |m|
        LogFile.new(EmployeeFolder.new(m))
      end

      Settings.with_mock_input "\nall\n\nWe met about stuff\n\n" * 2 do
        subject.command %w[avengers justice]
      end

      expected = ["  all\n", "  unspecified\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, members)
    end
  end
end
