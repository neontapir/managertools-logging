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
    [
      DiaryElement.new(:location, 'Location', 'Skype'),
      DiaryElement.new(:why_new_job, 'Why new job'),
      DiaryElement.new(:why_hybris, 'Why hybris'),
      DiaryElement.new(:goal, 'Career goal'),
      DiaryElement.new(:motivation, 'What motivates you'),
      DiaryElement.new(:challenge, 'What do you find challenging'),
      DiaryElement.new(:environment, 'Work environment'),
      DiaryElement.new(:why_not, 'Why not hire you'),
      DiaryElement.new(:personality, 'Personality'),
      DiaryElement.new(:relocation_needs, 'Relocation needs'),
      DiaryElement.new(:start_date, 'Desired start date'),
      DiaryElement.new(:compensation, 'Desired compensation'),
      DiaryElement.new(:notes, 'Notes'),
      DiaryElement.new(:actions, 'Actions')
    ]
  end

  def to_s
    initial = "=== Interview (#{format_date(@record[:datetime])})\n"
    InterviewEntry.elements_array.inject(initial) do |output, p|
      output << "#{p.prompt}::\n  #{wrap(@record[p.key] || p.default)}\n"
    end
  end
end
