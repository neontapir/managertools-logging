require 'erb'
require_relative 'mt_data_formatter'

include MtDataFormatter

class InterviewEntry
  attr_accessor :record

  def initialize(params = {})
    @record = params
  end

  def self.prompt(name)
    "For your interview with #{name}, enter the following:"
  end

  def self.get_elements_array
    [:location, :why_new_job, :why_hybris,
     :goal, :motivation, :challenge, :environment,
     :why_not, :personality, :candidate_location,
     :start_date, :compensation, :notes, :actions]
  end

  def to_s
    value = ERB.new(<<-BLOCK).result(binding)
=== Interview (#{format_date(@record[:datetime])})
Location::
  #{@record[:location] || "unspecified"}
Why new job::
  #{wrap(@record[:why_new_job] || "none")}
Why hybris::
  #{wrap(@record[:why_hybris] || "none")}
Career goal::
  #{wrap(@record[:goal] || "none")}
Motivation::
  #{wrap(@record[:motivation] || "none")}
Challenge::
  #{wrap(@record[:challenge] || "none")}
Work environment::
  #{wrap(@record[:environment] || "none")}
Why not hire::
  #{wrap(@record[:why_not] || "none")}
Personality::
  #{wrap(@record[:personality] || "none")}
Location and relocation needs including visa::
  #{wrap(@record[:candidate_location] || "none")}
Desired start date::
  #{wrap(@record[:start_date] || "none")}
Desired compensation::
  #{wrap(@record[:compensation] || "none")}
Notes::
  #{wrap(@record[:notes] || "none")}
Actions::
  #{wrap(@record[:actions] || "none")}

BLOCK
  end
end
