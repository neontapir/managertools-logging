require_relative 'word_wrap'

include WordWrap

class FeedbackEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
=== Feedback (#{format_date(@record[:datetime])})
Polarity::
  #{@record[:polarity].downcase || "positive"}
Content::
  #{wrap(@record[:content]) || "none"}

BLOCK
  end
end
