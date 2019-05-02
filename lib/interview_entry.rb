# frozen_string_literal: true

require_relative 'diary_date_element'
require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Template for a phone screening interview
class InterviewEntry < DiaryEntry
  include MtDataFormatter

  def prompt(name)
    "For your interview with #{name}, enter the following:"
  end

  # rubocop:disable Metrics/MethodLength
  def elements_array
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
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
  # rubocop:enable Metrics/MethodLength

  def to_s
    render 'Interview'
  end
end
