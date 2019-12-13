# frozen_string_literal: true

require 'chronic'
require 'date'
require_relative 'diary_element'
require_relative 'settings'

# Represents a date in a diary entry
class DiaryDateElement
  attr_reader :key, :label, :default, :prompt, :formatter

  # @!method initialize(key, label = key.to_s.capitalize, formatter = ->(x) { x.to_s })
  #   Create a new diary element
  #   @raise [ArgumentError] when label contains characters not allowed in Asciidoc definition lists
  def initialize(key, label = key.to_s.capitalize, options = {})
    # REVIEW: Research, this assertion may not actually be correct
    raise ArgumentError, 'Asciidoc labeled lists cannot contain special characters' unless label =~ /\A['\-A-Za-z ]+\z/

    @key = key
    @label = label
    @default = options.fetch(:default, Time.now)
    @formatter = options.fetch(:formatter, -> (x) { x.to_s })
    @prompt = options.fetch(:prompt, label)
  end

  # @!method obtain()
  #   Display the label, and get the element's value from the user
  def obtain
    return default unless prompt

    time = default
    if label
      value = Settings.console.ask "#{label}: " do |answer|
        answer.default = default.to_s
      end
      time = Chronic.parse(value.to_s, context: :past)
      time ||= default
    end
    @formatter.call time
  end
end
