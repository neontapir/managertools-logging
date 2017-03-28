require 'unicode'

# Commodity data formatting functions
module MtDataFormatter
  def unidown(input)
    Unicode.downcase(input)
  end

  def format_date(date)
    date.strftime('%B %e, %Y, %l:%M %p')
  end

  def strip_nonalnum(input)
    input.gsub(/[^-\p{Alnum}]/, '')
  end

  INDENT = '  '.freeze # this should match what's in the templates
  def wrap(input, width = 78)
    input
      .gsub(/(.{1,#{width - INDENT.length}})(\s+|\Z)/, "\\1\n#{INDENT}") \
      .chomp(INDENT)
      .chomp
  end

  module_function
end
