require 'pathname'
require 'facets/string/titlecase'

require_relative 'employee_folder'
require_relative 'log_file'
require_relative 'mt_data_formatter'
require_relative 'path_splitter'

# Represents a team member
class Employee
  extend MtDataFormatter
  extend PathSplitter

  attr_reader :team, :first, :last

  def initialize(**params)
    @team = params.fetch(:team)
    @first = params.fetch(:first)
    @last = params.fetch(:last)
  end

  def self.parse_dir(dir)
    paths = split_path dir
    _root, team, name = paths
    first, last = name.tr!('-', ' ').titlecase.strip.split(/\s+/)
    { team: team, first: first, last: last }
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

  def self.get(person, type = :generic)
    employee_spec = Employee.find person
    employee = if employee_spec.nil?
                 Employee.new(create_spec(type))
               else
                 employee_spec
               end
    employee
  end

  def self.create_spec(type)
    result = {}
    result[:team] = EmployeeFolder.candidates_root if type.to_sym == :interview
    [:team, :first, :last].each do |symbol|
      result[symbol] ||= ask "#{symbol.to_s.capitalize}: "
    end
    result
  end

  def file
    folder = EmployeeFolder.new self
    folder.ensure_exists
    LogFile.new folder
  end

  def eql?(other)
    return unless other.respond_to?(:team) && other.respond_to?(:first) && other.respond_to?(:last)
    team == other.team && first == other.first && last == other.last
  end

  def ==(other)
    eql?(other)
  end

  def canonical_name
    unidown "#{first}-#{last}"
  end

  def to_s
    "#{first.capitalize} #{last.capitalize}"
  end
end
