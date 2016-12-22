require 'fileutils'
require_relative 'employee_folder'
require_relative 'mt_file'

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
