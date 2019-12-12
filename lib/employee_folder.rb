# frozen_string_literal: true

require 'fileutils'
require_relative 'path_string_extensions'
require_relative 'settings'
require_relative 'string_extensions'

# Reparesents a folder that contains files about a direct report
# @attr_reader [Employee] employee the employee whose data resides in the folder
class EmployeeFolder
  using StringExtensions
  using PathStringExtensions

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
    first_name = employee.first.strip_nonalnum
    last_name = employee.last.strip_nonalnum
    "#{first_name}-#{last_name}".unidowncase
  end

  # The path to the file, relative to the parent folder of the root
  def path
    File.join(EmployeeFolder.root, employee.team.to_s.to_path, folder_name)
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
