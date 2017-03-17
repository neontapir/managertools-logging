require_relative 'mt_data_formatter'

include MtDataFormatter

# Template for documenting feedback given
class FeedbackEntry
  attr_accessor :record

  def initialize(**params)
    @record = params
  end

  def self.prompt(name)
    "With feedback for #{name}, enter the following:"
  end

  def self.elements_array
    [
      DiaryElement.new(:polarity, 'Polarity', 'positive'),
      DiaryElement.new(:content)
    ]
  end

  def to_s
    initial = "=== Feedback (#{format_date(@record[:datetime])})\n"
    FeedbackEntry.elements_array.inject(initial) do |output, p|
      output << "#{p.prompt}::\n  #{wrap(@record[p.key] || p.default)}\n"
    end
  end
end
