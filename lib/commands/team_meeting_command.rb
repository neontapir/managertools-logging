# frozen_string_literal: true

require_relative '../diary'
require_relative 'mt_command'
require_relative '../team'
require_relative '../string_extensions'

# Implements team meeting functionality
class TeamMeetingCommand < MtCommand
  include Diary
  using StringExtensions

  # command(arguments, options)
  #   Create an entry in each team member's file
  def command(arguments, _options = nil)
    entry = nil
    Array(arguments).each do |team_name|
      team = Team.find team_name
      raise "no such team #{team_name}" unless team

      team.members.each { |employee| entry = add_entry(entry, employee, team, team_name) }
    end
  end

  private

  def add_entry(entry, employee, team, team_name)
    entry ||= get_entry(
      :team_meeting,
      team_name.to_name,
      attendees: team.members
        .map { |m| m.to_s.to_name }
        .sort
        .join(', '),
      team: team,
    )
    employee.file.insert entry
    entry
  end
end
