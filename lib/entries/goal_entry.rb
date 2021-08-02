# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../time_extensions'

# Tempate used for team meetings, propagated to all team members' files
class GoalEntry < DiaryEntry
  using TimeExtensions

  # generates the interactive prompt string
  def prompt(name)
    "To record the goal for #{to_sentence(name)}, enter the following:"
  end

  # define the items included in the entry
  def elements
    result = [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryDateElement.new(:due_date, 'Due date', formatter: ->date { date.short_date }),
      DiaryElement.new(:goal),
    ]

    with_applies_to(result)
  end

  # render the entry into a string suitable for file insertion
  def entry_banner
    'Development Goal'
  end
end
