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
      self.gsub(/[^-\p{Alnum}]/, '')
    end

    # rubocop: disable Style/AsciiComments
    # Downcase a Unicode string
    # @example
    #   unidown('Äpple') #=> 'äpple'  
    def unidowncase
      Unicode.downcase self
    end
    # rubocop: enable Style/AsciiComments

    # @!method wrap(input, width = 78)
    #   Wrap input text on word boundaries, indenting all lines by INDENT
    #   @param [String] input the string to wrap
    #   @param [Integer] width the maximum number of characters in a line
    def wrap(width = 78)
      self
        .gsub(/(.{1,#{width - WRAP_INDENT.length}})(\s+|\Z)/, "\\1\n#{WRAP_INDENT}") \
        .chomp(WRAP_INDENT)
        .chomp
    end

    # @!method to_name(input)
    #   Put string in proper name casing
    #   @param [String] input the string to transform
    def to_name
      NameCase(self.upcase)
    end
  end

  # # Remove non-alphanumeric characters from a string
  # # @example Format a date
  # #   strip_nonalnum('f,o;o') #=> 'foo'
  # def strip_nonalnum(input)
  #   input.to_s.gsub(/[^-\p{Alnum}]/, '')
  # end

  # # rubocop: disable Style/AsciiComments
  # # Downcase a Unicode string
  # # @example
  # #   unidown('Äpple') #=> 'äpple'  
  # def unidown(input)
  #   Unicode.downcase input.to_s
  # end
  # # rubocop: enable Style/AsciiComments

  # # @!method wrap(input, width = 78)
  # #   Wrap input text on word boundaries, indenting all lines by INDENT
  # #   @param [String] input the string to wrap
  # #   @param [Integer] width the maximum number of characters in a line
  # def wrap(input, width = 78)
  #   input
  #     .to_s
  #     .gsub(/(.{1,#{width - INDENT.length}})(\s+|\Z)/, "\\1\n#{INDENT}") \
  #     .chomp(INDENT)
  #     .chomp
  # end

  # # @!method to_name(input)
  # #   Put string in proper name casing
  # #   @param [String] input the string to transform
  # def to_name(input)
  #   NameCase(input.to_s.upcase)
  # end
end
