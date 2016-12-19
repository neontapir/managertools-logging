require 'fileutils'
require 'unicode'

class EmployeeFolder
  attr_reader :employee

  def initialize(employee)
    @employee = employee
  end

  def no_alnum(input)
    input.gsub(/[^-\p{Alnum}]/,'')
  end

  def folder_name
    Unicode::downcase("#{no_alnum(@employee.first)}-#{no_alnum(@employee.last)}")
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
    File.join(EmployeeFolder.root, @employee.team.downcase, folder_name)
  end

  def create
    FileUtils.mkdir_p path
  end

  def ensure_exists
    if not Dir.exist? path
      puts "Creating #{path}"
      create
    end
  end

  def to_s
    path
  end
end
