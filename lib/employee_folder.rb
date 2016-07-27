require 'fileutils'

class EmployeeFolder
  attr_reader :employee

  def initialize(employee)
    @employee = employee
  end

  def folder_name
    "#{@employee.first.gsub(/\W/,'')}-#{@employee.last.gsub(/\W/,'')}".downcase
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
