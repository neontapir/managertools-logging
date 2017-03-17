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
    [DiaryElement.new(:content)]
  end

  def to_s
    initial = "=== Observation (#{format_date(@record[:datetime])})\n"
    ObservationEntry.elements_array.inject(initial) do |output, p|
      output << "#{p.prompt}::\n  #{wrap(@record[p.key] || p.default)}\n"
    end
  end
end
