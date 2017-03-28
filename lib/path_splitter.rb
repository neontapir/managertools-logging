# Splits path into team and member name components
module PathSplitter
  # extend self

  def split_path(path)
    Pathname.new(path).each_filename.to_a
  end

  module_function
end
