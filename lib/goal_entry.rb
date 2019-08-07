# frozen_string_literal: true

require_relative 'diary_date_element'
require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Tempate used for team meetings, propagated to all team members' files
class GoalEntry < DiaryEntry
  include MtDataFormatter

  def prompt(name)
    personalized = name[','] ? '' : " for #{name}"
    "To record the goal#{personalized}, enter the following:"
  end

  def elements_array
    result = [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryDateElement.new(:due_date, 'Due date', formatter: -> date { format_short_date(date) }),
      DiaryElement.new(:goal)
    ]

    with_applies_to(result)
  end

  def to_s
    render 'Development Goal'
  end
end
