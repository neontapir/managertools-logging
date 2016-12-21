require 'fileutils'
require 'unicode'

class EmployeeFolder
  attr_reader :employee

  def initialize(employee)
    @employee = employee
  end

  def strip_nonalnum(input)
    input.gsub(/[^-\p{Alnum}]/,'')
  end

  def folder_name
    Unicode::downcase("#{strip_nonalnum(@employee.first)}-#{strip_nonalnum(@employee.last)}")
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
    File.join(EmployeeFolder.root, Unicode::downcase(@employee.team), folder_name)
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
