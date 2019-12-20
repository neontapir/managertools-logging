# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../settings'

# Tempate used for team meetings, propagated to all team members' files
class TeamMeetingEntry < DiaryEntry
  # generates the interactive prompt string
  def prompt(team)
    personalized = team[','] ? '' : team
    "For your #{personalized} team meeting, enter the following:"
  end

  # define the items included in the entry
  def elements
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:team, 'Team', default: nil, prompt: nil),
      DiaryElement.new(:attendees),
      DiaryElement.new(:location, 'Location', default: Settings.meeting_location_default || 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions),
    ]
  end

  # items in the header_items array will not be included in the body of the entry, just the header
  def header_items
    [:datetime, :team]
  end

  # render the entry into a string suitable for file insertion
  def to_s
    render('Team Meeting')
  end
end
