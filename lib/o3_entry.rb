require_relative 'mt_data_formatter'

include MtDataFormatter

# Template for a one-on-one meeting
class O3Entry
  attr_accessor :record

  def initialize(**params)
    @record = params
  end

  def self.prompt(name)
    "For your 1:1 with #{name}, enter the following:"
  end

  def self.elements_array
    [[:location, 'unspecified'], :notes, :actions]
  end

  def to_s
    <<-BLOCK
=== One-on-One (#{format_date(@record[:datetime])})
Location::
  #{@record[:location] }
Notes::
  #{wrap(@record[:notes])}
Actions::
  #{wrap(@record[:actions])}

BLOCK
  end
end
