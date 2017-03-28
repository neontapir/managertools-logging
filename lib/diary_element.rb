require 'highline/import'

# A single item in a diary entry, like "Location"
class DiaryElement
  attr_reader :key, :prompt, :default

  NONE = 'none'.freeze

  def initialize(key, prompt = key.to_s.capitalize, default = NONE)
    @key = key
    @prompt = prompt
    @default = default

    # TODO: Research, this may not actually be true
    raise ArgumentError, 'Asciidoc labeled lists cannot contain special characters' unless @prompt =~ /\A['\-A-Za-z ]+\z/
  end

  def obtain
    ask "#{prompt}: " do |answer|
      answer.default = default
    end
  end
end
