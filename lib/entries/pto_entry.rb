# frozen_string_literal: true

require 'chronic'
require 'chronic_duration'
require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../mt_data_formatter'
require_relative '../settings'

# Template for a one-on-one meeting
class PtoEntry < DiaryEntry
  include MtDataFormatter

  def elements_array
    [
      DiaryElement.new(:duration, 'Duration', default: '0', prompt: nil),
      DiaryDateElement.new(:start_time, 'Start date', formatter: -> x { x.strftime '%B %e, %Y' }),
      DiaryDateElement.new(:end_time, 'End date', formatter: -> x { x.strftime '%B %e, %Y' }),
      DiaryElement.new(:reason, 'Reason', default: Settings.pto_default || 'unspecified'),
    ]
  end

  def prompt(name)
    "To record paid time off for #{name}, enter the following:"
  end

  # One day in seconds
  ONE_DAY = 86400

  # A hook to modify data after prompting for responses
  def post_create(data)
    start_time = Chronic.parse(data[:start_time])
    data[:datetime] = start_time

    end_time = Chronic.parse(data[:end_time])
    duration = ChronicDuration.output(ONE_DAY + (end_time - start_time))
    data[:duration] = duration || 'unknown'
    data
  end

  def to_s
    render 'Paid time off'
  end
end