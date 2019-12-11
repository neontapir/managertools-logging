# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../mt_data_formatter'
require_relative '../settings'

# Tempate used for team meetings, propagated to all team members' files
class TeamMeetingEntry < DiaryEntry
  include MtDataFormatter

  def prompt(team)
    personalized = team[','] ? '' : "#{team}"
    "For your #{personalized} team meeting, enter the following:"
  end

  def elements
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:team, 'Team', default: nil, prompt: nil),
      DiaryElement.new(:attendees),
      DiaryElement.new(:location, 'Location', default: Settings.location_default || 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions)
    ]
  end

  # # A hook to modify data after prompting for responses
  # def post_create(data)
  #   if data[:attendees] == DiaryElement::DEFAULT_VALUE
  #     data[:attendees] = data[:team].members
  #   end

  #   data
  # end

  # items in the header_items array will not be included in the body of the entry, just the header
  def header_items
    [:datetime, :team]
  end

  def to_s
    render('Team Meeting')
  end
end
