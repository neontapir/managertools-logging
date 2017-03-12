require 'fileutils'
require_relative 'mt_data_formatter'
require_relative 'settings'

# Reparesents a folder that contains files about a direct report
class EmployeeFolder
  attr_reader :employee
  include MtDataFormatter

  def initialize(employee)
    @employee = employee
  end

  def folder_name
    first_name = strip_nonalnum(@employee.first)
    last_name = strip_nonalnum(@employee.last)
    unidown("#{first_name}-#{last_name}")
  end

  def self.root
    Settings.root
  end

  def self.candidates_root
    Settings.candidates_root
  end

  def path
    File.join(EmployeeFolder.root, unidown(@employee.team), folder_name)
  end

  def create
    FileUtils.mkdir_p path
  end

  def ensure_exists
    create unless Dir.exist? path
  end

  def to_s
    path
  end
end
