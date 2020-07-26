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
  #
  #   Note: Chronic does some strange things around parsing 'today'
  #         that causes diary entries to be inserted in non-intuitive
  #         places in rare circumstances:
  #         1) For other days besides today, the relative date is at noon.
  #            For 'today', it's now. That's why I specify noon if 'today'
  #            is given.
  #         2) When using context: :past, if you specify 'today' and a
  #            time that hasn't happened yet, 'today' becomes 'now'.
  #            That's why I disable past context if today is passed.
  def obtain
    return default unless prompt

    time = label ? obtain_with_label : default
    @value = @formatter.call time
    value
  end

  private

  def obtain_with_label
    input = Settings.console.ask "#{label}: " do |answer|
      answer.default = default.to_s
    end
    input = 'today noon' if input.match?(/^\s*today\s*$/i)
    context = input.include?('today') ? {} : { context: :past }
    time = Chronic.parse(input.to_s, context)
    time || default
  end
end
