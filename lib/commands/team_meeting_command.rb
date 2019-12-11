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

      log_message_for team_name, team.members
    end
  end

  private

  def log_message_for(team_name, members)
    entry = nil
    members.each do |employee|
      entry ||= get_entry(:team_meeting, to_name(team_name), applies_to: members.map{|s| to_name(s)}.join(', '))
      employee.file.insert entry
    end
  end

  # HACK: Copied from Diary to alter header, fix this to allow injection
  def get_entry(type, team_name, initial_record = {})
    data = template? ? {} : create_entry(type, team_name, initial_record)
    # HACK: For Multiple member, I want to show the injected value in the
    #   template. That creates a chicken and the egg problem. During
    #   create_entry, the contents of initial_value aren't retained.
    #   This kludge forces them back in. Fix this.
    data.merge! initial_record
    entry_type = DiaryEntry.get type
    entry_type.new data
  end
end
