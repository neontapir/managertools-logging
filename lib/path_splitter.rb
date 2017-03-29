# Splits path into team and member name components
module PathSplitter

  # Turn a relative path into an array of folders and the filename
  # @example Parsing a path
  #  split_path('foo/bar/baz.txt') #=> ['foo', 'bar', 'baz.txt']
  def split_path(path)
    Pathname.new(path).each_filename.to_a
  end

  module_function
end
