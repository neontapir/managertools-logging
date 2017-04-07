require 'fileutils'

# Basic file utilities
module MtFile
  # Ensure a file exists
  def ensure_exists
    FileUtils.mkdir_p(File.dirname(path))
    FileUtils.touch path
  end

  # @abstract returns the file system location of the file
  def path
    raise NotImplementedError, 'A MtFile must define its #path'
  end

  # Represent the file as its filesystem location
  def to_s
    path
  end
end
