require_relative 'mt_data_formatter'

include MtDataFormatter

# Template for a phone screening interview
class InterviewEntry
  attr_accessor :record

  def initialize(**params)
    @record = params
  end

  def self.prompt(name)
    "For your interview with #{name}, enter the following:"
  end

  def self.elements_array
    [:location, :why_new_job, :why_hybris,
     :goal, :motivation, :challenge, :environment,
     :why_not, :personality, :candidate_location,
     :start_date, :compensation, :notes, :actions]
  end

  NONE = 'none'.freeze
  def to_s
    <<-BLOCK
=== Interview (#{format_date(@record[:datetime])})
Location::
  #{@record[:location] || 'unspecified'}
Why new job::
  #{wrap(@record[:why_new_job] || NONE)}
Why hybris::
  #{wrap(@record[:why_hybris] || NONE)}
Career goal::
  #{wrap(@record[:goal] || NONE)}
Motivation::
  #{wrap(@record[:motivation] || NONE)}
Challenge::
  #{wrap(@record[:challenge] || NONE)}
Work environment::
  #{wrap(@record[:environment] || NONE)}
Why not hire::
  #{wrap(@record[:why_not] || NONE)}
Personality::
  #{wrap(@record[:personality] || NONE)}
Location and relocation needs including visa::
  #{wrap(@record[:candidate_location] || NONE)}
Desired start date::
  #{wrap(@record[:start_date] || NONE)}
Desired compensation::
  #{wrap(@record[:compensation] || NONE)}
Notes::
  #{wrap(@record[:notes] || NONE)}
Actions::
  #{wrap(@record[:actions] || NONE)}

BLOCK
  end
end
