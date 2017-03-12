require 'fileutils'

# Basic file utilities
module MtFile
  def ensure_exists
    create unless File.exist? path
  end

  def create
    FileUtils.touch path
  end

  def path
    raise NotImplementedError, 'A MtFile must define its #path'
  end

  def to_s
    path
  end
end
