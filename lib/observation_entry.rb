require_relative 'mt_data_formatter'

include MtDataFormatter

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
    #value = ERB.new(<<-BLOCK).result(binding)
    <<-BLOCK
=== Observation (#{format_date(@record[:datetime])})
Content::
  #{wrap(@record[:content]) || "none"}

BLOCK
  end
end
