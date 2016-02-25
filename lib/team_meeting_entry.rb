require 'erb'
require_relative 'word_wrap'

include WordWrap

class TeamMeetingEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def self.prompt(name)
    "For your team meeting, enter the following:"
  end

  def self.get_elements_array
    [:attendees, :location, :notes, :actions]
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
=== Team Meeting (#{format_date(@record[:datetime])})
Attendees::
  #{wrap(@record[:attendees] || "none")}
Location::
  #{@record[:location] || "unspecified"}
Notes::
  #{wrap(@record[:notes] || "none")}
Actions::
  #{wrap(@record[:actions] || "none")}

BLOCK
  end
end
