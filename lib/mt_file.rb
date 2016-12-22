require 'fileutils'
require_relative 'employee_folder'

module MtFile
  def ensure_exists
    if not File.exist? path
      puts "Creating #{path}"
      create
    end
  end

  def create
    FileUtils.touch path
  end

  def to_s
    path
  end
end
