# frozen_string_literal: true

require './lib/log_file.rb'
require './lib/team_meeting_command.rb'

require_relative 'captured_io'

describe TeamMeetingCommand do
  include CapturedIO

  module Diary
    undef :template? if method_defined? :template?
    def template?
      false # force interactive mode, avoid reading global variables
    end
  end

  before(:all) do
    FileUtils.mkdir_p('data/avengers/tony-stark')
    FileUtils.mkdir_p('data/avengers/steve-rogers')
  end

  after(:all) do
    FileUtils.rm_r('data/avengers')
  end

  context 'with the Avengers team' do
    it 'will append the entry to all team members' do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
      members = [tony, steve]

      members.each do |m|
        LogFile.new(EmployeeFolder.new(m))
      end

      input = StringIO.new("\nall\n\nWe met about stuff\n\n")

      command = TeamMeetingCommand.new
      with_captured(input) do |_|
        command.command ['avengers']
      end

      expected = ["  all\n", "  unspecified\n", "  We met about stuff\n", "  none\n"]
      expected.each do |answer|
        members.each do |member|
          expect(File.readlines(member.file.path)).to include(answer)
        end
      end
    end
  end
end