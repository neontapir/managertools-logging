# frozen_string_literal: true

require './lib/log_file.rb'
require './lib/multiple_member_command.rb'

require_relative 'captured_io'

describe MultipleMemberCommand do
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

  context 'with multiple people' do
    it 'will append the entry to all their logs' do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
      members = [tony, steve]

      members.each do |m|
        LogFile.new(EmployeeFolder.new(m))
      end

      input = StringIO.new("\nSpoke about important things\n")

      command = MultipleMemberCommand.new
      with_captured(input) do |_|
        command.command ['stark', 'rogers']
      end

      expected = ["  Spoke about important things\n"]
      expected.each do |answer|
        members.each do |member|
          expect(File.readlines(member.file.path)).to include(answer)
        end
      end
    end
  end

  it 'will raise error when given a bad employee search string' do
    tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
    members = [tony]

    members.each do |m|
      LogFile.new(EmployeeFolder.new(m))
    end

    input = StringIO.new("\n\nDummy\n")

    command = MultipleMemberCommand.new
    with_captured(input) do |_|
      expect { command.command ['BAD_NAME'] }.to raise_error "unable to find employee 'BAD_NAME'"
    end
  end
end