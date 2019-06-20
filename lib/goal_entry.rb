# frozen_string_literal: true

require_relative 'diary_date_element'
require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Tempate used for team meetings, propagated to all team members' files
class GoalEntry < DiaryEntry
  include MtDataFormatter

  def prompt(*)
    "To record the goal, enter the following:"
  end

  def elements_array
    result = [
      DiaryDateElement.new(:datetime, 'Effective date'),
      DiaryDateElement.new(:due_date, 'Due date', -> date { format_short_date(date) }),
      DiaryElement.new(:goal),
    ]

    if (record.key? :applies_to)
      applies_to = record.fetch(:applies_to)
      result.insert(1, DiaryElement.new(:applies_to, 'Applies to', applies_to)) if (applies_to.include? ',')
    end

    result
  end

  def to_s
    render 'Development Goal'
  end
end