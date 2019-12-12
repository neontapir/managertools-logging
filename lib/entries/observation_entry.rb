# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'

# Template for an observation
class ObservationEntry < DiaryEntry
  def prompt(name)
    personalized = name[','] ? '' : " for #{name}"
    "Enter your observation#{personalized}:"
  end

  def elements
    result = [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryElement.new(:content)
    ]
    with_applies_to(result)
  end

  def to_s
    render 'Observation'
  end
end
