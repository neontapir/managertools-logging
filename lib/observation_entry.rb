require_relative 'word_wrap'

include WordWrap

class ObservationEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def self.prompt(name)
    "Enter your observation for #{name}:"
  end

  def self.get_elements_array
    [:content]
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
=== Observation (#{format_date(@record[:datetime])})
Content::
  #{wrap(@record[:content]) || "none"}

BLOCK
  end
end
