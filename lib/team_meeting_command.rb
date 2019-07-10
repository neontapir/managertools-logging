# frozen_string_literal: true

require_relative 'diary'
require_relative 'team'

# Implements team meeting functionality
class TeamMeetingCommand
  include Diary

  # @!method command(arguments)
  #   Create an entry in each team member's file
  def command(arguments, options = nil)
    Array(arguments).each do |team_name|
      team = Team.find team_name
      raise "no such team #{team_name}" unless team

      log_message_for team.members
    end
  end

  private

  def log_message_for(members)
    any_team_member = members.first
    entry = get_entry :team_meeting, any_team_member

    members.each do |employee|
      employee.file.insert entry
    end
  end
end
