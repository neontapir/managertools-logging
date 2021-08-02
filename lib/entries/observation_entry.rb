# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'

# Template for an observation
class ObservationEntry < DiaryEntry
  # generates the interactive prompt string
  def prompt(name)
    "Enter your observation for #{to_sentence(name)}:"
  end

  # define the items included in the entry
  def elements
    result = [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:content),
    ]
    with_applies_to(result)
  end

  # render the entry into a string suitable for file insertion
  def entry_banner
    'Observation'
  end
end
