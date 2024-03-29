# frozen_string_literal: true

require './lib/employee'
require './lib/employee_folder'
require './lib/log_file'
require './lib/commands/team_meeting_command'
require_relative 'file_contents_validation_helper'

RSpec.describe TeamMeetingCommand do
  include FileContentsValidationHelper

  subject(:team_meeting) do
    command = described_class.new
    allow(command).to receive(:template?).and_return false
    command
  end

  def make_folders(*group)
    group.each do |hero|
      hero_folder = File.dirname(hero.file.path)
      expect(File).not_to exist hero_folder
      FileUtils.mkdir_p hero_folder
    end
  end

  def remove_folders
    %w[avengers justice-league].each do |group|
      group_folder = File.join(Settings.root, group)
      FileUtils.rm_r group_folder if File.exist? group_folder
    end
  end

  context 'with the Avengers team' do
    thing = Employee.new(team: 'Avengers', first: 'Benjamin', last: 'Grimm')
    vision = Employee.new(team: 'Avengers', first: 'Victor', last: 'Shade')

    before do
      make_folders thing, vision
    end

    after do
      remove_folders
    end

    it 'will append the entry to all team members' do
      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        team_meeting.command ['avengers']
      end

      expected = ["  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, [vision, thing])
    end

    it 'the team member names will be in alphabetical order' do
      Settings.with_mock_input "\n\n\nWe met about more stuff\n\n" do
        team_meeting.command ['avengers']
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
      make_folders firebird, falcon, diana
    end

    after do
      remove_folders
    end

    it "will append the entry to each team's members" do
      Settings.with_mock_input "\n\n\nWe met about stuff\n\n" do
        team_meeting.command %w[avengers justice]
      end

      expected = ["  alcove\n", "  We met about stuff\n", "  none\n"]
      verify_answers_propagated(expected, [firebird, falcon, diana])
    end
  end
end
