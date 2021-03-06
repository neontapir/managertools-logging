# frozen_string_literal: true

require 'namecase'
require 'titleize'
require 'unicode'

# Commodity string formatting functions
module StringExtensions
  # The standard indentation (two spaces)
  WRAP_INDENT = '  ' # this should match what's in the templates

  refine String do
    # Remove non-alphanumeric characters from a string
    # @example Format a date
    #   'f,o;o'.strip_nonalnum #=> 'foo'
    def strip_nonalnum
      gsub(/[^-\p{Alnum}]/, '')
    end

    # rubocop: disable Style/AsciiComments
    # Downcase a Unicode string
    # @example
    #   unidown('Äpple') #=> 'äpple'
    def unidowncase
      Unicode.downcase self
    end

    # rubocop: enable Style/AsciiComments

    # wrap(input, width = 78)
    #   Wrap input text on word boundaries, indenting all lines by INDENT
    #   @param [String] input the string to wrap
    #   @param [Integer] width the maximum number of characters in a line
    def wrap(width = 78)
      gsub(/(.{1,#{width - WRAP_INDENT.length}})(\s+|\Z)/, "\\1\n#{WRAP_INDENT}")
        .chomp(WRAP_INDENT)
        .chomp
    end

    # to_name(input)
    #   Put string in proper name casing
    #   @param [String] input the string to transform
    def to_name
      NameCase(upcase)
    end
  end
end
