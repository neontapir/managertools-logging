require_relative 'word_wrap'

include WordWrap

class ObservationEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
=== Observation (#{@record[:datetime].strftime("%B %e, %Y, %l:%M %p")})
Content::
  #{wrap(@record[:content],100) || "none"}

BLOCK
  end
end
