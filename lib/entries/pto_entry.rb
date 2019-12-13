# frozen_string_literal: true

require 'chronic'
require 'chronic_duration'
require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../string_extensions'
require_relative '../settings'

# Template for a one-on-one meeting
class PtoEntry < DiaryEntry
  using StringExtensions

  def elements
    [
      DiaryElement.new(:duration, 'Duration', default: '0', prompt: nil),
      DiaryDateElement.new(:start_time, 'Start date', formatter: -> x { x.short_date }),
      DiaryDateElement.new(:end_time, 'End date', formatter: -> x { x.short_date }),
      DiaryElement.new(:reason, 'Reason', default: Settings.pto_default || 'unspecified')
    ]
  end

  def prompt(name)
    "To record paid time off for #{name}, enter the following:"
  end

  # One day in seconds
  ONE_DAY = 86_400

  # A hook to modify data after prompting for responses
  def post_create(data)
    start_time = Chronic.parse(data.fetch(:start_time))
    data[:datetime] = start_time

    end_time = Chronic.parse(data.fetch(:end_time))
    duration = ChronicDuration.output(ONE_DAY + (end_time - start_time))
    data[:duration] = duration || 'unknown'
    data
  end

  def to_s
    render 'Paid time off'
  end
end
