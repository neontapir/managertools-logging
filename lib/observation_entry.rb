# frozen_string_literal: true

require_relative 'diary_date_element'
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
      DiaryDateElement.new(:datetime, 'Effective date', Time.now.to_s),
      DiaryElement.new(:content)
    ]
  end

  def to_s
    render('Observation')
  end
end
