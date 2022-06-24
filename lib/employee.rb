# frozen_string_literal: true

require 'attr_extras'
require_relative 'employee_finder'
require_relative 'employee_folder'
require_relative 'settings'
require_relative 'string_extensions'

# A data container for employee data, used during searching folders for
# employee records
# rubocop:disable Lint/StructNewOverride
EmployeeSpecification = Struct.new(:team, :first, :last, keyword_init: true) do
  # convert a hash to an employee
  def to_employee
    Employee.new(team: team, first: first, last: last)
  end
end
# rubocop:enable Lint/StructNewOverride

# Represents a team member, a person assigned to a team
# @attr_reader [String] team the name of the team the person belongs to
# @attr_reader [String] first the first name of the team member
# @attr_reader [String] last the last name of the team member
class Employee
  include Comparable
  extend EmployeeFinder
  using StringExtensions

  attr_value_initialize[:team!, :first!, :last!] do
    raise ArgumentError, 'Team must not be empty' if team.to_s.empty?
    raise ArgumentError, 'First name must not be empty' if first.to_s.empty?
    raise ArgumentError, 'Last name must not be empty' if last.to_s.empty?
  end

  # The name used in folder creation
  # @return [String] the folder name
  def canonical_name
    @canonical_name ||= begin
        first_name, last_name = [first, last].map { |n| n.tr(' ', '-').strip_nonalnum }
        "#{first_name}-#{last_name}".unidowncase
      end
  end

  # Get the LogFile for the employee
  #
  # @return [LogFile] the employee's log file
  def file
    folder = EmployeeFolder.new self
    LogFile.new folder
  end

  # Get the overview file location for the employee
  #
  # @return [string] the employee's log file
  def overview_location
    folder = EmployeeFolder.new self
    File.join(folder.to_s, Settings.overview_filename)
  end

  # Object comparison by its fields
  #
  # @param [Type] other the object to compare
  # @return [Integer] -1 (other less than), 0 (equal), or 1 (greater than)
  def <=>(other)
    [:team, :first, :last].each do |attribute|
      return -1 unless other.respond_to?(attribute)
    end
    [team, first, last] <=> [other.team, other.first, other.last]
  end

  # Object equality by fieldwise comparison
  #
  # @param [Type] other the object to compare
  # @return [Boolean] whether both object's fields are equal
  def eql?(other)
    self.<=>(other).zero?
  end

  # Computes an object's hash
  # @return [fixnum] a number representing the uniqueness of the object
  def hash
    [team, first, last].hash
  end

  # The display name, in title case
  # @return [String] the display name
  def to_s
    "#{first} #{last}".to_name
  end
end
