require 'highline/import'

# A single item in a diary entry, like "Location"
# @attr_reader [Symbol] key the key to use for the entry's data dictionary
# @attr_reader [String] prompt the phrase to display when prompting the user for its value
# @attr_reader [String] default the default value of the entry
class DiaryElement
  attr_reader :key, :prompt, :default

  # The value used if the element's default value is not specified during object construction
  DEFAULT_VALUE = 'none'.freeze

  # Create a new diary element
  # @raise [ArgumentError] when prompt contains characters not allowed in Asciidoc definition lists
  def initialize(key, prompt = key.to_s.capitalize, default = DEFAULT_VALUE)
    @key = key
    @prompt = prompt
    @default = default

    # TODO: Research, this may not actually be true
    raise ArgumentError, 'Asciidoc labeled lists cannot contain special characters' unless @prompt =~ /\A['\-A-Za-z ]+\z/
  end

  # Display the prompt, and get the user's input for the element's value
  def obtain
    ask "#{prompt}: " do |answer|
      answer.default = default
    end
  end
end
