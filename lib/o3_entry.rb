# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Template for a one-on-one meeting
class O3Entry < DiaryEntry
  include MtDataFormatter

  def prompt(name)
    "For your 1:1 with #{name}, enter the following:"
  end

  def elements_array
    [
      DiaryElement.new(:datetime, 'Effective date', Time.now.to_s),
      DiaryElement.new(:location, 'Location', 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions)
    ]
  end

  def to_s
    render('One-on-One')
  end
end
