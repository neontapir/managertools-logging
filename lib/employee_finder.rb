require 'pathname'
require 'facets/string/titlecase'

require_relative 'employee'
require_relative 'employee_folder'
require_relative 'log_file'
require_relative 'mt_data_formatter'
require_relative 'path_splitter'
require_relative 'settings'

# Represents a employee search provider
module EmployeeFinder
  include PathSplitter

  # Parse the path as though it is an employee spec and return the result
  #
  # @param [String] dir the location of a person
  # @return [Hash] the employee data represented by the location
  def parse_dir(dir)
    paths = split_path dir
    _root, team, name = paths
    { team: team }.merge(parse_name(name))
  end

  # Parse a string as though it is part of an employee spec and return the result
  def parse_name(name)
    first, last = name.tr('-', ' ').titlecase.strip.split(/\s+/)
    { first: first, last: last }
  end

  # Given a part of employee data, find the first matching employee
  #
  # @param [String] key the lookup data needed to find the employee
  # @return [Employee] an Employee object
  def find(key)
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
  def get(person, type = :generic)
    employee_spec = find person
    if employee_spec.nil?
      Employee.new(create_spec(type, parse_name(person)))
    else
      employee_spec
    end
  end

  # Create a specification describing a person
  #
  # @param [String] type the type of entry
  # @return [Hash] a specification of the employee
  def create_spec(type, person)
    result = {}
    result[:team] = if type.to_sym.eql? :interview
                      EmployeeFolder.candidates_root
                    else
                      obtain('Team', EmployeeFolder.candidates_root)
                    end
    result[:first] = obtain('First', person[:first] || 'Zaphod')
    result[:last] = obtain('Last', person[:last] || 'Beeblebrox')
    result
  end

  # Display the prompt, and get the element's value from the user
  def obtain(prompt, default = '')
    Settings.console.ask "#{prompt}: " do |answer|
      answer.default = default
    end
  end

  module_function
end
