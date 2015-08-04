require_relative 'word_wrap'

include WordWrap

class FeedbackEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
=== Feedback (#{@record[:datetime].strftime("%B %e, %Y, %l:%M %p")})
Polarity::
  #{@record[:polarity].downcase || "positive"}
Content::
  #{wrap(@record[:content],100) || "none"}

BLOCK
  end
end
