require 'unicode'

module MtDataFormatter
  def unidown(input)
    Unicode::downcase(input)
  end

  def format_date(date)
    date.strftime("%B %e, %Y, %l:%M %p")
  end

  def strip_nonalnum(input)
    input.gsub(/[^-\p{Alnum}]/,'')
  end

  INDENT = '  ' # this should match what's in the templates
  def wrap(s, width=78)
    s.gsub(/(.{1,#{width - INDENT.length}})(\s+|\Z)/, "\\1\n#{INDENT}") \
     .chomp("#{INDENT}").chomp
  end

  module_function
end
