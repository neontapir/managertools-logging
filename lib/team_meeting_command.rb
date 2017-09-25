# frozen_string_literal: true

require_relative 'diary'
require_relative 'team'

include Diary

# A team meeting
class TeamMeetingCommand
  # @!method command(arguments)
  #   Create an entry in each team member's file
  def command(arguments)
    members = get_members(arguments.first)
    any_team_member = members.first
    entry = get_entry :team_meeting, any_team_member

    members.each do |employee|
      log_file = employee.file
      log_file.ensure_exists
      log_file.append entry
    end
  end

  def get_members(team_name)
    team = Team.find team_name
    team.members
  end
end
