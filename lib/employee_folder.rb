# frozen_string_literal: true

require 'fileutils'
require_relative 'mt_data_formatter'
require_relative 'path_formatter'
require_relative 'settings'

# Reparesents a folder that contains files about a direct report
# @attr_reader [Employee] employee the employee whose data resides in the folder
class EmployeeFolder
  include MtDataFormatter
  include PathFormatter

  attr_reader :employee

  class << self
    # The root folder where data is stored, taken from Settings
    def root
      Settings.root
    end

    # The folder where data is stored for candidates, taken from Settings
    def candidates_root
      Settings.candidates_root
    end
  end

  # Create a new EmployeeFolder object
  def initialize(employee)
    @employee = employee
  end

  # The canonical name of the folder
  def folder_name
    first_name = strip_nonalnum employee.first
    last_name = strip_nonalnum employee.last
    unidown "#{first_name}-#{last_name}"
  end

  # The path to the file, relative to the parent folder of the root
  def path
    File.join(EmployeeFolder.root, to_path_string(employee.team), folder_name)
  end

  # Create a file system folder at path
  def create
    FileUtils.mkdir_p path
  end

  # Make sure a file system folder exists at the path
  def ensure_exists
    create unless Dir.exist? path
  end

  # The string representation
  # @return the path
  def to_s
    path
  end
end
