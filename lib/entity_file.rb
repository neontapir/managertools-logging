# frozen_string_literal: true

require 'attr_extras'
require 'fileutils'
require_relative 'employee_folder'
require_relative 'mt_file'

# A file containing data about an entity
# @attr_reader [EmployeeFolder] folder the folder containing the file
# @attr_reader [String] filename the name of the file
class EntityFile
  include MtFile

  attr_value_initialize :folder, :filename do
    raise ArgumentError, 'Folder cannot be empty' if folder.to_s.empty?
    raise ArgumentError, 'Filename cannot be empty' if filename.to_s.empty?
  end

  # The file system path to this EntityFile
  def path
    File.join(folder.path, filename)
  end
end
