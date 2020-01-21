# frozen_string_literal: true

require 'fileutils'
require_relative 'employee_folder'
require_relative 'mt_file'

# A file containing data about an entity
# @attr_reader [EmployeeFolder] folder the folder containing the file
# @attr_reader [String] filename the name of the file
class EntityFile
  include MtFile
  attr_reader :folder, :filename

  # initialize(folder, filename)
  #   @param [String] folder The folder containing the file
  #   @param [String] filename The name of the file
  #   @raise [ArgumentError] when folder or file are empty
  #   Create an employee file object
  def initialize(folder, filename)
    @folder, @filename = folder, filename

    raise ArgumentError, 'Folder cannot be empty' if folder.to_s.empty?
    raise ArgumentError, 'Filename cannot be empty' if filename.to_s.empty?
  end

  # path
  #   The file system path to this EntityFile
  def path
    File.join(folder.path, filename)
  end
end
