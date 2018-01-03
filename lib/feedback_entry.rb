# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Template for documenting feedback given
class FeedbackEntry < DiaryEntry
  include MtDataFormatter

  def prompt(name)
    "With feedback for #{name}, enter the following:"
  end

  def elements_array
    [
      DiaryElement.new(:polarity, 'Polarity', 'positive'),
      DiaryElement.new(:content)
    ]
  end

  def to_s
    render('Feedback')
  end
end
