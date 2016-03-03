# TODO: rename to more general purpose module or split functionality
module WordWrap
  def format_date(date)
    date.strftime("%B %e, %Y, %l:%M %p")
  end

  def wrap(s, width=78)
    s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n").chomp
  end
end
