require 'fileutils'
require_relative 'employee_folder'
require_relative 'mt_file'

# A file containing data about a direct report
class EmployeeFile
  include MtFile
  attr_accessor :folder, :filename

  def initialize(folder, filename)
    @folder = folder
    @filename = filename
  end

  def path
    File.join(@folder.path, @filename)
  end
end
