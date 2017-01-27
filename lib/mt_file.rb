require 'fileutils'
#require_relative 'employee_folder'

module MtFile
  def ensure_exists
    if not File.exist? path
      #puts "Creating #{path}"
      create
    end
  end

  def create
    FileUtils.touch path
  end

  def path
    fail NotImplementedError, "A MtFile must define its #path"
  end

  def to_s
    path
  end
end
