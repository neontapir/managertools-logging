require 'fileutils'
require_relative 'mt_data_formatter'

class EmployeeFolder
  attr_reader :employee
  include MtDataFormatter

  def initialize(employee)
    @employee = employee
  end

  def folder_name
    unidown("#{strip_nonalnum(@employee.first)}-#{strip_nonalnum(@employee.last)}")
  end

  # TODO: make this configurable
  def self.root
    'data'
  end

  # TODO: make this configurable
  def self.candidates_root
    'candidates'
  end

  def path
    File.join(EmployeeFolder.root, unidown(@employee.team), folder_name)
  end

  def create
    FileUtils.mkdir_p path
  end

  def ensure_exists
    if not Dir.exist? path
      #puts "Creating #{path}"
      create
    end
  end

  def to_s
    path
  end
end
