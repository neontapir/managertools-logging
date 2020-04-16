# frozen_string_literal: true

require_relative '../diary_date_element'
require_relative '../diary_element'
require_relative 'diary_entry'
require_relative '../settings'

# Template for a phone screening interview
class FourByFourEntry < DiaryEntry
  # generates the interactive prompt string
  def prompt(name)
    "For your 4x4 session with #{name}, enter the following:"
  end

  # define the items included in the entry
  def elements
    [
      DiaryElement.new(:last_quarter, 'Last quarter accomplishments', prompt: 'What have you accomplished and what were you unable to achieve this last quarter?'),
      DiaryElement.new(:current_quarter, 'Current quarter accomplishments', prompt: 'What do you hope to accomplish in the current quarter? Is there anything you can identify now that may interfere with you achieving one or more of you your goals for this quarter? How can I best support you in achieving these goals?'),
      DiaryElement.new(:department, 'Departmental effectiveness', prompt: 'What can we do as a department or departmental leadership team to be more effective?'),
      DiaryElement.new(:career, 'Career progress', prompt: 'Answer one or more of the following: How satisfied are you with the progression of your career? What do you want to work on over the next quarter that will help you to develop your career at LR? What talent do you have of which I may be unaware o that you would like to use more? What is something that you think would be fun to learn that would fit into your long-term career goals? How can I help?'),
    ]
  end

  # render the entry into a string suitable for file insertion
  def entry_banner
    'Four by four'
  end
end
