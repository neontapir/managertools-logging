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
    tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
    steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')

    before :context do
      [tony, steve].each do |hero|
        FileUtils.mkdir_p File.dirname(hero.file.path)
      end
    end

    after :context do
      FileUtils.rm_r tony.file.path
    end

    it 'will append the entry to all team members' do
      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        subject.command ['avengers']
      end

      expected = ["  Steve Rogers, Tony Stark\n", "  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, [tony, steve])
    end
  end

  context 'with multiple teams' do
    tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
    steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
    diana = Employee.new(team: 'Justice League', first: 'Diana', last: 'Prince')

    def get_team_folder(log_file_path)
      File.dirname(File.dirname(log_file_path))
    end

    before do
      [tony, steve, diana].each do |hero|
        FileUtils.mkdir_p File.dirname(hero.file.path)
      end
    end

    after do
      [tony, steve, diana].map { |hero| get_team_folder(hero.file.path) }.uniq.each do |team_folder|
        FileUtils.rm_r team_folder
      end
    end

    it "will append the entry to each team's members" do
      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        subject.command %w[avengers justice]
      end

      expected = ["  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, [tony, steve, diana])
    end
  end
end
