# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../settings'

# Template for a one-on-one meeting
class OneOnOneEntry < DiaryEntry
  # generates the interactive prompt string
  def prompt(name)
    "For your 1:1 with #{name}, enter the following:"
  end

  # define the items included in the entry
  def elements
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:location, 'Location', default: Settings.meeting_location_default || 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions),
    ]
  end

  # render the entry into a string suitable for file insertion
  def entry_banner
    'One-on-One'
  end
end
