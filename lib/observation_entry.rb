# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

include MtDataFormatter

# Template for an observation
class ObservationEntry < DiaryEntry
  def prompt(name)
    "Enter your observation for #{name}:"
  end

  def elements_array
    [DiaryElement.new(:content)]
  end

  def to_s
    render('Observation')
  end
end
