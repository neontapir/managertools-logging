require_relative 'mt_data_formatter'

include MtDataFormatter

# Template for an observation
class ObservationEntry
  attr_accessor :record

  def initialize(**params)
    @record = params
  end

  def self.prompt(name)
    "Enter your observation for #{name}:"
  end

  def self.elements_array
    [:content]
  end

  def to_s
    <<-BLOCK
=== Observation (#{format_date(@record[:datetime])})
Content::
  #{wrap(@record[:content]) || 'none'}

BLOCK
  end
end
