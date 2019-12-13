# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../settings'

# Template for a phone screening interview
class InterviewEntry < DiaryEntry
  def prompt(name)
    "For your interview with #{name}, enter the following:"
  end

  def elements
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:location, 'Location', default: Settings.voip_meeting_default),
      DiaryElement.new(:position, 'Position', default: 'SE1'),
      DiaryElement.new(:other_panel_members, 'Other panel members', default: 'solo'),
      DiaryElement.new(:notes, 'Notes'),
      DiaryElement.new(:recommendation, 'Recommendation')
    ]
  end

  def to_s
    render 'Interview'
  end
end
