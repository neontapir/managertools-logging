# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Template for an observation
class ObservationEntry < DiaryEntry
  include MtDataFormatter

  def prompt(name)
    "Enter your observation for #{name}:"
  end

  def elements_array
    [
      DiaryElement.new(:datetime, 'Effective date |today|', Date.today.to_time),
      DiaryElement.new(:content)
    ]
  end

  def to_s
    render('Observation')
  end
end
