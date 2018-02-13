# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Tempate used for team meetings, propagated to all team members' files
class TeamMeetingEntry < DiaryEntry
  include MtDataFormatter

  def prompt(*)
    'For your team meeting, enter the following:'
  end

  def elements_array
    [
      DiaryElement.new(:datetime, 'Effective date', Time.now.to_s),
      DiaryElement.new(:attendees),
      DiaryElement.new(:location, 'Location', 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions)
    ]
  end

  def to_s
    render('Team Meeting')
  end
end
