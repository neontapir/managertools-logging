# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../settings'

# Template for documenting feedback given
class FeedbackEntry < DiaryEntry
  # generates the interactive prompt string
  def prompt(name)
    personalized = name[','] ? '' : " to #{name}"
    "To give feedback#{personalized}, enter the following:"
  end

  # define the items included in the entry
  def elements
    result = [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:polarity, 'Polarity', default: Settings.feedback_polarity_default || 'positive'),
      DiaryElement.new(:content),
    ]

    with_applies_to(result)
  end

  # render the entry into a string suitable for file insertion
  def to_s
    render 'Feedback'
  end
end
