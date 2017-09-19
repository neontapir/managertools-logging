# frozen_string_literal: true

require_relative 'settings'

# A single item in a diary entry, like "Location"
# @!attribute [r] key
#   @return [Symbol] the key to use for the diary entry's data dictionary, should be unique
# @!attribute [r] prompt
#   @return [String] the phrase to display when prompting the user for its value
# @!attribute [r] default
#   @return [String] the default value of the element
class DiaryElement
  attr_reader :key, :prompt, :default

  # The value used if the element's default value is not specified during object construction
  DEFAULT_VALUE = 'none'

  # @!method initialize(key, prompt = key.to_s.capitalize, default = DEFAULT_VALUE)
  #   Create a new diary element
  #   @raise [ArgumentError] when prompt contains characters not allowed in Asciidoc definition lists
  def initialize(key, prompt = key.to_s.capitalize, default = DEFAULT_VALUE)
    # TODO: Research, this assertion may not actually be true
    raise ArgumentError, 'Asciidoc labeled lists cannot contain special characters' unless prompt =~ /\A['\-A-Za-z ]+\z/

    @key = key
    @prompt = prompt
    @default = default
  end

  # @!method obtain()
  #   Display the prompt, and get the element's value from the user
  def obtain
    return default if prompt.nil?
    Settings.console.ask "#{prompt}: " do |answer|
      answer.default = default
    end
  end
end
