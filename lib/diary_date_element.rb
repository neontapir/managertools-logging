# frozen_string_literal: true

require 'chronic'
require_relative 'diary_element'
require_relative 'settings'

class DiaryDateElement < DiaryElement
  # @!method obtain()
  #   Display the prompt, and get the element's value from the user
  def obtain
    return default unless prompt
    value = Settings.console.ask "#{prompt}: " do |answer|
      answer.default = default
    end
    (Chronic.parse(value) || Time.now).to_s
  end
end