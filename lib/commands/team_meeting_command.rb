# frozen_string_literal: true

require_relative '../diary'
require_relative '../team'
require_relative '../mt_data_formatter'

# Implements team meeting functionality
class TeamMeetingCommand
  include Diary
  include MtDataFormatter

  # @!method command(arguments, options)
  #   Create an entry in each team member's file
  def command(arguments, _ = nil)
    Array(arguments).each do |team_name|
      team = Team.find team_name
      raise "no such team #{team_name}" unless team

      log_message_for team.members
    end
  end

  private

  def log_message_for(members)
    entry = nil
    members.each do |employee|
      entry ||= get_entry(:team_meeting, members.join(','), applies_to: members.map{|s| to_name(s)}.join(', '))
      employee.file.insert entry
    end
  end
end
