require 'erb'
require_relative 'mt_data_formatter'

include MtDataFormatter

class InterviewEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def self.prompt(name)
    "For your interview with #{name}, enter the following:"
  end

  def self.get_elements_array
    [:location, :notes, :actions]
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
=== Interview (#{format_date(@record[:datetime])})
Location::
  #{@record[:location] || "unspecified"}
Notes::
  #{wrap(@record[:notes] || "none")}
Actions::
  #{wrap(@record[:actions] || "none")}

BLOCK
  end
end
