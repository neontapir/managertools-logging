require 'erb'
require_relative 'word_wrap'

include WordWrap

class O3Entry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
== One-on-One (#{@record[:datetime].strftime("%B %e, %Y, %l:%M %p")})
Location::
  #{@record[:location] || "Unspecified"}
Notes::
  #{wrap(@record[:notes],100)}
Actions::
  #{wrap(@record[:actions] || "None",100)}
BLOCK
  end
end
