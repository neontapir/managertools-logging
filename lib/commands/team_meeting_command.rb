# frozen_string_literal: true

require_relative '../diary'
require_relative '../team'
require_relative '../string_extensions'

# Implements team meeting functionality
class TeamMeetingCommand
  include Diary
  using StringExtensions

  # @!method command(arguments, options)
  #   Create an entry in each team member's file
  def command(arguments, _ = nil)
    entry = nil
    Array(arguments).each do |team_name|
      team = Team.find team_name
      raise "no such team #{team_name}" unless team

      members = team.members
      members.each do |employee|
        entry ||= get_entry(
          :team_meeting,
          team_name.to_name,
          attendees: members
            .map { |m| m.to_s.to_name }
            .join(', '),
          team: team
        )
        employee.file.insert entry
      end
    end
  end
end
