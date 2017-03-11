require_relative 'mt_data_formatter'

include MtDataFormatter

class FeedbackEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def self.prompt(name)
    "With feedback for #{name}, enter the following:"
  end

  def self.get_elements_array
    [[:polarity, "positive"], :content]
  end

  def to_s
    <<-BLOCK
=== Feedback (#{format_date(@record[:datetime])})
Polarity::
  #{@record[:polarity].downcase || "positive"}
Content::
  #{wrap(@record[:content]) || "none"}

BLOCK
  end
end
