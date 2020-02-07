# frozen_string_literal: true

require 'attr_extras'
require 'chronic'
require 'date'
require_relative 'diary_element'
require_relative 'settings'

# Represents a date in a diary entry
class DiaryDateElement
  attr_value :key, :label, :value
  attr_reader :default, :prompt, :formatter

  # initialize(key, label = key.to_s.capitalize, formatter = ->(x) { x.to_s })
  #   Create a new diary element
  #   @raise [ArgumentError] when label contains characters not allowed in Asciidoc definition lists
  def initialize(key, label = key.to_s.capitalize, options = {})
    # REVIEW: Research, this assertion may not actually be correct
    raise ArgumentError, 'Asciidoc labeled lists cannot contain special characters' \
      unless label.match?(/\A['\-A-Za-z ]+\z/)

    @key = key
    @label = label
    @default = options.fetch(:default, Time.now)
    @value = default
    @formatter = options.fetch(:formatter, ->(x) { x.to_s })
    @prompt = options.fetch(:prompt, label)
  end

  # obtain()
  #   Display the label, and get the element's value from the user
  def obtain
    return default unless prompt

    time = default
    if label
      input = Settings.console.ask "#{label}: " do |answer|
        answer.default = default.to_s
      end
      time = Chronic.parse(input.to_s, context: :past)
      time ||= default
    end
    @value = @formatter.call time
    value
  end
end
