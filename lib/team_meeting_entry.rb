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
    [:attendees, :location, :notes, :actions]
  end

  def to_s
    <<-BLOCK
=== #{@team} Team Meeting (#{format_date(@record[:datetime])})
Attendees::
  #{wrap(@record[:attendees] || 'none')}
Location::
  #{@record[:location] || 'unspecified'}
Notes::
  #{wrap(@record[:notes] || 'none')}
Actions::
  #{wrap(@record[:actions] || 'none')}

BLOCK
  end
end
