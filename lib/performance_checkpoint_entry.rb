# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Template for an performance checkpoint
class PerformanceCheckpointEntry < DiaryEntry
  include MtDataFormatter

  def prompt(name)
    "Enter your performance checkpoint for #{name}:"
  end

  def elements_array
    [
      DiaryElement.new(:datetime, 'Effective date', Time.now.to_s),
      DiaryElement.new(:content)
    ]
  end

  def to_s
    render('Performance Checkpoint')
  end
end
