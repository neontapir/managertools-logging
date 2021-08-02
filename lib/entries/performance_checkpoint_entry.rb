# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'

# Template for an performance checkpoint
class PerformanceCheckpointEntry < DiaryEntry
  # generates the interactive prompt string
  def prompt(name)
    "Enter your performance checkpoint for #{to_sentence(name)}:"
  end

  # define the items included in the entry
  def elements
    [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:content),
    ]
  end

  # render the entry into a string suitable for file insertion
  def entry_banner
    'Performance Checkpoint'
  end
end
