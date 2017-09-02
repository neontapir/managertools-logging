require 'unicode'

# Commodity data formatting functions
module MtDataFormatter
  # Downcase a Unicode string
  # @example
  #   unidown('Äpple') #=> 'äpple'
  def unidown(input)
    Unicode.downcase(input)
  end

  # Format a date in our specific format
  # @example Format a date
  #   format_date(Time.new(2002)) #=> 'January  1, 2002, 12:00 AM'
  def format_date(date)
    date.strftime('%B %e, %Y, %l:%M %p')
  end

  # Remove non-alphanumeric characters from a string
  # @example Format a date
  #   strip_nonalnum('f,o;o') #=> 'foo'
  def strip_nonalnum(input)
    input.gsub(/[^-\p{Alnum}]/, '')
  end

  # The standard indentation (two spaces)
  INDENT = '  '.freeze # this should match what's in the templates

  # @!method wrap(input, width = 78)
  #   Wrap input text on word boundaries, indenting all lines by INDENT
  #   @param [String] input the string to wrap
  #   @param [Integer] width the maximum number of characters in a line
  def wrap(input, width = 78)
    input
      .gsub(/(.{1,#{width - INDENT.length}})(\s+|\Z)/, "\\1\n#{INDENT}") \
      .chomp(INDENT)
      .chomp
  end

  module_function
end
