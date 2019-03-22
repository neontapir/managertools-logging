# frozen_string_literal: true

require_relative 'diary_date_element'
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
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:content)
    ]
  end

  def to_s
    render 'Performance Checkpoint'
  end
end
