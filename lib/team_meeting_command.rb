# frozen_string_literal: true

require_relative 'diary'
require_relative 'team'

# A team meeting
class TeamMeetingCommand
  include Diary

  # @!method command(arguments)
  #   Create an entry in each team member's file
  def command(arguments)
    team_name = arguments.first
    raise 'missing team name argument' unless team_name

    members = Team.find(team_name).members
    any_team_member = members.first
    entry = get_entry :team_meeting, any_team_member

    members.each do |employee|
      employee.file.insert entry
    end
  end
end
