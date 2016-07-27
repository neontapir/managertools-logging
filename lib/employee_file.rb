require_relative 'employee_folder'

class EmployeeFile
  attr_accessor :folder, :filename

  def initialize(folder, filename)
    @folder = folder
    @filename = filename
  end

  def path
    File.join(@folder.path, @filename)
  end

  def ensure_exists
    if not File.exist? path
      puts "Creating #{path}"
      create
    end
  end

  def to_s
    path
  end
end
