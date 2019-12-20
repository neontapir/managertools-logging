# frozen_string_literal: true

require 'chronic'
require 'chronic_duration'
require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../string_extensions'
require_relative '../settings'
require_relative '../time_extensions'

# Template for a time off entry
class PtoEntry < DiaryEntry
  using StringExtensions
  using TimeExtensions

  # define the items included in the entry
  def elements
    [
      DiaryElement.new(:duration, 'Duration', default: '0', prompt: nil),
      DiaryDateElement.new(:start_time, 'Start date', formatter: -> x { x.short_date }),
      DiaryDateElement.new(:end_time, 'End date', formatter: -> x { x.short_date }),
      DiaryElement.new(:reason, 'Reason', default: Settings.pto_default || 'unspecified')
    ]
  end

  # generates the interactive prompt string
  def prompt(name)
    "To record paid time off for #{name}, enter the following:"
  end

  # One day in seconds
  ONE_DAY = 86_400

  # A hook to modify data after prompting for responses
  def post_create(data)
    start_time = Chronic.parse(data.fetch(:start_time))
    end_time = Chronic.parse(data.fetch(:end_time))
    
    if end_time < start_time
      data[:start_time], data[:end_time] = data[:end_time], data[:start_time]
      start_time, end_time = end_time, start_time
    end
    data[:datetime] = start_time

    duration = ChronicDuration.output(ONE_DAY + (end_time - start_time))
    data[:duration] = duration || 'unknown'
    
    data
  end

  # render the entry into a string suitable for file insertion
  def to_s
    render 'Paid time off'
  end
end
