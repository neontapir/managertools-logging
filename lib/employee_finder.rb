# frozen_string_literal: true

require 'pathname'

require_relative 'employee_folder'
require_relative 'log_file'
require_relative 'mt_data_formatter'
require_relative 'path_formatter'
require_relative 'settings'

# Represents a employee search provider
module EmployeeFinder
  include PathFormatter

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
    words = name.tr('-', ' ').titlecase.strip.split(/\s+/)
    first = words.shift
    { first: first, last: words.map(&:titlecase).join('-') }
  end

  # Given a part of employee data, find the first matching employee
  #
  # @param [String] search_string the lookup data needed to find the employee
  # @return [Employee] an Employee object
  def find(search_string)
    root = EmployeeFolder.root
    result = []
    key = search_string.downcase
    Dir.glob("#{root}/*/*") do |folder|
      next unless Dir.exist? folder
      if /#{key}/ =~ folder.to_s
        employee = parse_dir folder
        result << Employee.new(employee)
      end
    end
    result.sort.first
  end

  # Description of method
  #
  # @param [Hash] person employee data
  # @param [Symbol] type of employee, in practice generic or candidate
  # @return [Hash] a specification of the employee
  def get(person, type = :generic)
    employee_spec = find person
    employee_spec || Employee.new(create_spec(type, parse_name(person)))
  end

  # Create a specification describing a person
  #
  # @param [String] type the type of entry
  # @return [Hash] a specification of the employee
  def create_spec(type, person)
    result = {}
    root = EmployeeFolder.candidates_root
    result[:team] = if type.to_sym.eql? :interview
                      root
                    else
                      obtain('Team', root)
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
end
