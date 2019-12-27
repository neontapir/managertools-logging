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

  context 'with the Avengers team' do
    thing = Employee.new(team: 'Avengers', first: 'Benjamin', last: 'Grimm')
    vision = Employee.new(team: 'Avengers', first: 'Victor', last: 'Shade')

    before do
      [thing, vision].each do |hero|
        FileUtils.mkdir_p File.dirname(hero.file.path)
      end
    end

    after do
      FileUtils.rm_r thing.file.path
    end

    it 'will append the entry to all team members' do
      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        subject.command ['avengers']
      end

      expected = ["  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, [vision, thing])
    end

    it 'the team member names will be in alphabetical order' do
      Settings.with_mock_input "\n\n\nWe met about more stuff\n\n" do
        subject.command ['avengers']
      end

      expected = ["  Benjamin Grimm, Victor Shade\n"]
      verify_answers_propagated(expected, [vision, thing])
    end
  end

  context 'with multiple teams' do
    firebird = Employee.new(team: 'Avengers', first: 'Bonita', last: 'Juárez')
    falcon = Employee.new(team: 'Avengers', first: 'Snap', last: 'Wilson')
    diana = Employee.new(team: 'Justice League', first: 'Diana', last: 'Prince')

    def get_team_folder(log_file_path)
      File.dirname(File.dirname(log_file_path))
    end

    before do
      [firebird, falcon, diana].each do |hero|
        FileUtils.mkdir_p File.dirname(hero.file.path)
      end
    end

    after do
      [firebird, falcon, diana].map { |hero| get_team_folder(hero.file.path) }.uniq.each do |team_folder|
        FileUtils.rm_r team_folder
      end
    end

    it "will append the entry to each team's members" do
      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        subject.command %w[avengers justice]
      end

      expected = ["  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, [firebird, falcon, diana])
    end
  end
end
