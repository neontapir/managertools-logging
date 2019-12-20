# frozen_string_literal: true

require_relative 'settings'

# A single item in a diary entry, like "Location"
# @!attribute [r] key
#   @return [Symbol] the key to use for the diary entry's data dictionary, should be unique
# @!attribute [r] label
#   @return [String] the phrase to label or identify the value in the output file
# @!attribute [r] default
#   @return [String] the default value of the element
# @!attribute [r] prompt
#   @return [String] the phrase to display when prompting the user for its value
class DiaryElement
  # The value used if the element's default value is not specified during object construction
  DEFAULT_VALUE = 'none'

  attr_reader :key, :label, :default, :prompt

  # @!method initialize(key, label = key.to_s.capitalize, options = {})
  #   Create a new diary element
  #   @raise [ArgumentError] when label contains characters not allowed in Asciidoc definition lists
  def initialize(key, label = key.to_s.capitalize, options = {})
    # REVIEW: Research, this assertion may not actually be correct
    raise ArgumentError, 'Asciidoc labeled lists cannot contain special characters' unless label =~ /\A['\-A-Za-z ]+\z/

    @key = key
    @label = label
    @default = options[:default] || DEFAULT_VALUE
    @prompt = options.key?(:prompt) ? options[:prompt] : label
  end

  # @!method obtain()
  #   Display the label, and get the element's value from the user
  def obtain
    return default unless prompt

    Settings.console.ask "#{label}: " do |answer|
      answer.default = default
    end
  end

  # Print a detailed view of a diary element for debugging
  def inspect
    "<DiaryElement:#{object_id} with key: '#{key}', label: '#{label}', default: '#{default}', prompt: '#{prompt}'>"
  end
end
