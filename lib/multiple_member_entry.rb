# frozen_string_literal: true

require_relative 'diary_element'
require_relative 'diary_entry'
require_relative 'mt_data_formatter'

# Tempate used for team meetings, propagated to all team members' files
class MultipleMemberEntry < DiaryEntry
  include MtDataFormatter
  attr_reader :folks

  def prompt(*)
    "For your note for multiple members, enter the following:"
  end

  def elements_array
    [
      DiaryElement.new(:datetime, 'Effective date', Time.now.to_s),
      DiaryElement.new(:note),
    ]
  end

  def to_s
    render('Multiple Member Note')
  end
end