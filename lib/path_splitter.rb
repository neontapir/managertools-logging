module PathSplitter

  def split_path(path)
      Pathname(path).each_filename.to_a
  end

  module_function
end
