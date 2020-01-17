# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../settings'

# Template for a phone screening interview
class InterviewEntry < DiaryEntry
  # generates the interactive prompt string
  def prompt(name)
    "For your interview with #{name}, enter the following:"
  end

  # define the items included in the entry
  def elements
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:location, 'Location', default: Settings.voip_meeting_default),
      DiaryElement.new(:position, 'Position', default: 'SE1'),
      DiaryElement.new(:other_panel_members, 'Other panel members', default: 'solo'),
      DiaryElement.new(:notes, 'Notes'),
      DiaryElement.new(:recommendation, 'Recommendation'),
    ]
  end

  # render the entry into a string suitable for file insertion
  def entry_banner
    'Interview'
  end
end
