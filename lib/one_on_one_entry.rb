# frozen_string_literal: true

require_relative 'diary_date_element'
require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'
require_relative 'settings'

# Template for a one-on-one meeting
class OneOnOneEntry < DiaryEntry
  include MtDataFormatter

  def prompt(name)
    "For your 1:1 with #{name}, enter the following:"
  end

  def elements_array
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:location, 'Location', Settings.location_default || 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions)
    ]
  end

  def to_s
    render 'One-on-One'
  end
end
