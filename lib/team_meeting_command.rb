require_relative 'diary'
require_relative 'team'

include Diary

# A team meeting
class TeamMeetingCommand
  # @!method command(arguments)
  #   Create an entry in each team member's file
  def command(arguments)
    team_name = arguments.first
    team = Team.find team_name
    members = team.members
    any_team_member = members.first

    entry = get_entry :team_meeting, any_team_member

    members.each do |employee|
      log_file = employee.file
      log_file.ensure_exists
      log_file.append entry
    end
  end
end
