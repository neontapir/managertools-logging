require 'pathname'
require 'facets/string/titlecase'
require_relative 'employee_file'
require_relative 'employee_folder'
require_relative 'path_splitter'

class Employee
  extend PathSplitter

  attr_reader :team, :first, :last

  def initialize(params = {})
    @team = params[:team]
    @first = params[:first]
    @last = params[:last]
    #puts "DEBUG: created employee, first: '#{first}', last: '#{last}' on '#{team}'"
  end

  def self.parse_dir(dir)
    paths = split_path dir
    root, team, name = paths
    name = name.gsub!('-', ' ').titlecase.strip.split(/\s+/)
    first = name[0]
    last = name[1]
    {team: team, first: first, last: last}
  end

  def self.find(key)
    root = EmployeeFolder.root
    Dir.glob("#{root}/*/*") do |d|
      next unless Dir.exist? d
      if /#{key}/ =~ d.to_s
        employee = parse_dir d
        return Employee.new employee
      end
    end
  end

  def to_s
    "#{@first.capitalize} #{@last.capitalize}"
  end
end
