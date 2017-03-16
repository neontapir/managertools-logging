require_relative 'mt_data_formatter'

include MtDataFormatter

# TODO: This is experimental and not in use. Doesn't prompt correctly.
# Template for a phone screening interview
class NewInterviewEntry
  attr_accessor :record

  def initialize(**params)
    @record = params
  end

  def self.prompt(name)
    "For your interview with #{name}, enter the following:"
  end

  PROMPTS = {
     :location => 'Location',
     :why_new_job => 'Why new job',
     :why_hybris => 'Why hybris',
     :goal => 'Career goal',
     :motivation => 'What motivates you',
     :challenge => 'What do you find challenging',
     :environment => 'Work environment',
     :why_not => 'Why not hire you',
     :personality => 'Personality',
     :candidate_location => 'Location and relocation needs including visa',
     :start_date => 'Desired start date',
     :compensation => 'Desired compensation',
     :notes => 'Notes',
     :actions => 'Actions'
   }.freeze

  def self.elements_array
    PROMPTS.keys
  end

  NONE = 'none'.freeze

  def to_s
    output = "=== Interview (#{format_date(@record[:datetime])})\n\n"
    PROMPTS.each do |k, v|
      response = wrap(@record[k] || NONE)
      output << "#{v}::\n  #{response}\n"
    end
    output
  end
end
