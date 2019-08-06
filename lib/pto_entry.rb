# frozen_string_literal: true

require 'chronic'
require 'chronic_duration'
require_relative 'diary_date_element'
require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'
require_relative 'settings'

# Template for a one-on-one meeting
class PtoEntry < DiaryEntry
  include MtDataFormatter

  def elements_array
    [
      DiaryDateElement.new(:start_time, 'Start date', Time.now, -> x { x.strftime '%B %e, %Y' }),
      DiaryDateElement.new(:end_time, 'End date', Time.now, -> x { x.strftime '%B %e, %Y' }),
      DiaryElement.new(:reason, 'Reason', Settings.pto_default || 'unspecified'),
    ]
  end

  def prompt(name)
    "To record paid time off for #{name}, enter the following:"
  end

  # A hook to modify data after prompting for responses
  def post_create(data)
    data[:datetime] = data[:start_time]
    # TODO: Add to elements_array so it's in the body, but find a way that we don't prompt for it
    # data[:duration] = ChronicDuration.output(Chronic.parse(data[:end_time]) - Chronic.parse(data[:start_time]))
    data
  end

  def to_s
    render 'Paid time off'
  end
end