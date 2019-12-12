# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../time_extensions'

# Tempate used for team meetings, propagated to all team members' files
class GoalEntry < DiaryEntry
  using TimeExtensions

  def prompt(name)
    personalized = name[','] ? '' : " for #{name}"
    "To record the goal#{personalized}, enter the following:"
  end

  def elements
    result = [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryDateElement.new(:due_date, 'Due date', formatter: -> date { date.short_date }),
      DiaryElement.new(:goal)
    ]

    with_applies_to(result)
  end

  def to_s
    render 'Development Goal'
  end
end
