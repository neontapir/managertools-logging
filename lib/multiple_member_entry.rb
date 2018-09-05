# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Tempate used for team meetings, propagated to all team members' files
class MultipleMemberEntry < DiaryEntry
  include MtDataFormatter

  def prompt(*)
    "For your note for multiple members, enter the following:"
  end

  def elements_array
    [
      DiaryElement.new(:datetime, 'Effective date', Time.now.to_s),
      DiaryElement.new(:applies_to, 'Applies to', @record.fetch(:applies_to)),
      DiaryElement.new(:note),
    ]
  end

  def to_s
    render('Multiple Member Note')
  end
end