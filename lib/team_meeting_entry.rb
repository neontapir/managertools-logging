require_relative 'mt_data_formatter'

include MtDataFormatter

# Tempate used for team meetings, propagated to all team members' files
class TeamMeetingEntry
  attr_accessor :record, :team

  def initialize(**params)
    @record = params
  end

  def self.prompt(*)
    'For your team meeting, enter the following:'
  end

  def self.elements_array
    [
      DiaryElement.new(:attendees),
      DiaryElement.new(:location, 'Location', 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions)
    ]
  end

  def to_s
    initial = "=== Team Meeting (#{format_date(@record[:datetime])})\n"
    TeamMeetingEntry.elements_array.inject(initial) do |output, p|
      output << "#{p.prompt}::\n  #{wrap(@record[p.key] || p.default)}\n"
    end
  end
end
