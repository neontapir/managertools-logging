require 'fileutils'
require_relative 'employee_folder'
require_relative 'mt_file'

# A file containing data about a direct report
# @attr_reader [EmployeeFolder] folder the folder containing the file
# @attr_reader [String] filename the name of the file
class EmployeeFile
  include MtFile
  attr_reader :folder, :filename

  # Create an employee file object
  def initialize(folder, filename)
    @folder = folder
    @filename = filename
  end

  # The file system path to this EmployeeFile
  def path
    File.join(folder.path, filename)
  end
end
