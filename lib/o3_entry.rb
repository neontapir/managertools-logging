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
    [
      DiaryElement.new(:location, 'Location', 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions)
    ]
  end

  def to_s
    initial = "=== One-on-One (#{format_date(@record[:datetime])})\n"
    O3Entry.elements_array.inject(initial) do |output, p|
      output << "#{p.prompt}::\n  #{wrap(@record[p.key] || p.default)}\n"
    end
  end
end
