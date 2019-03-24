# frozen_string_literal: true

require 'chronic'
require 'date'
require_relative 'diary_element'
require_relative 'mt_data_formatter'
require_relative 'settings'

class DiaryDateElement
  attr_reader :key, :prompt
  include MtDataFormatter

  # @!method initialize(key, prompt = key.to_s.capitalize, formatter = ->(x) { x.to_s })
  #   Create a new diary element
  #   @raise [ArgumentError] when prompt contains characters not allowed in Asciidoc definition lists
  def initialize(key, prompt = key.to_s.capitalize, formatter = ->(x) { x.to_s })
    # TODO: Research, this assertion may not actually be correct
    raise ArgumentError, 'Asciidoc labeled lists cannot contain special characters' unless prompt =~ /\A['\-A-Za-z ]+\z/

    @key = key
    @prompt = prompt
    @formatter = formatter
  end

  def default
    Time.now
  end

  # @!method obtain()
  #   Display the prompt, and get the element's value from the user
  def obtain
    time = default
    if prompt
      value = Settings.console.ask "#{prompt}: " do |answer|
        answer.default = default.to_s
      end
      time = Chronic.parse(value.to_s, context: :past)
      time = default if time.nil?
    end
    @formatter.call time
  end
end