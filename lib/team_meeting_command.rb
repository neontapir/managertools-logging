# frozen_string_literal: true

require_relative 'diary'
require_relative 'team'

# A team meeting
class TeamMeetingCommand
  include Diary

  # @!method command(arguments)
  #   Create an entry in each team member's file
  def command(arguments)
    arguments.each do |team_name|
      team = Team.find team_name
      raise "no such team #{team_name}" if team.nil?

      log_message_for team
    end
  end

  def log_message_for(team)
    members = team.members
    any_team_member = members.first
    entry = get_entry :team_meeting, any_team_member

    members.each do |employee|
      employee.file.insert entry
    end
  end
end
