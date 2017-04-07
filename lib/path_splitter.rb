# Splits path into team and member name components
module PathSplitter
  # Turn a relative path into an array of folders and the filename
  # @example Parsing a path
  #  split_path('foo/bar/baz.txt') #=> ['foo', 'bar', 'baz.txt']
  def split_path(path)
    raise ArgumentError, 'Nil path' if path.nil?
    Pathname.new(path).each_filename.to_a
  end

  # Determine if a path matches the given string
  def matches?(path, key)
    raise ArgumentError, 'Nil path' if path.nil?
    (Dir.exist? path) && (/#{key}/ =~ path)
  end

  module_function
end
