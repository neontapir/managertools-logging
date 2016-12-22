# TODO: rename to more general purpose module or split functionality
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

  def wrap(s, width=78)
    s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n").chomp
  end

  module_function
end
