# A single item in a diary entry, like "Location"
class DiaryElement
  attr_accessor :key, :prompt, :default

  NONE = 'none'.freeze

  def initialize(key, prompt = key.to_s.capitalize, default = NONE)
    @key = key
    @prompt = prompt
    @default = default
  end
end
