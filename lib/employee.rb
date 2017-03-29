require 'pathname'
require 'facets/string/titlecase'

require_relative 'employee_folder'
require_relative 'log_file'
require_relative 'mt_data_formatter'
require_relative 'path_splitter'

# Represents a team member, a person assigned to a team
# @attr_reader [String] team the name of the team the person belongs to
# @attr_reader [String] first the first name of the team member
# @attr_reader [String] last the last name of the team member
class Employee
  extend MtDataFormatter
  extend PathSplitter

  attr_reader :team, :first, :last

  # Create a new Employee object
  #
  # @param [Hash] params the employee data
  def initialize(**params)
    @team = params.fetch(:team)
    @first = params.fetch(:first)
    @last = params.fetch(:last)
  end

  # Description of method
  #
  # @param [String] dir the location of a person
  # @return [Hash] the employee data represented by the location
  def self.parse_dir(dir)
    paths = split_path dir
    _root, team, name = paths
    first, last = name.tr!('-', ' ').titlecase.strip.split(/\s+/)
    { team: team, first: first, last: last }
  end

  # Given a part of employee data, find the first matching employee
  #
  # @param [String] key the lookup data needed to find the employee
  # @return [Employee] an Employee object
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

  # Description of method
  #
  # @param [Hash] person employee data
  # @param [Symbol] type of employee, in practice generic or candidate
  # @return [Hash] a specification of the employee
  def self.get(person, type = :generic)
    employee_spec = Employee.find person
    employee = if employee_spec.nil?
                 Employee.new(create_spec(type))
               else
                 employee_spec
               end
    employee
  end

  # Create a specification describing a person
  #
  # @param [String] type the type of entry
  # @return [Hash] a specification of the employee
  def self.create_spec(type)
    result = {}
    result[:team] = EmployeeFolder.candidates_root if type.to_sym == :interview
    [:team, :first, :last].each do |symbol|
      result[symbol] ||= ask "#{symbol.to_s.capitalize}: "
    end
    result
  end

  # Get the LogFile for the employee
  #
  # @return [LogFile] the employee's log file
  def file
    folder = EmployeeFolder.new self
    folder.ensure_exists
    LogFile.new folder
  end

  # Object equality by its fields
  #
  # @param [Type] other the object to compare
  # @return [Boolean] whether the object is equivalent
  def eql?(other)
    return unless other.respond_to?(:team) && other.respond_to?(:first) && other.respond_to?(:last)
    team == other.team && first == other.first && last == other.last
  end

  # Object equality
  def ==(other)
    eql?(other)
  end

  # The name used in folder creation
  def canonical_name
    unidown "#{first}-#{last}"
  end

  # The display name
  def to_s
    "#{first.capitalize} #{last.capitalize}"
  end
end
