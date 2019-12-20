# frozen_string_literal: true

require_relative 'employee_finder'
require_relative 'employee_folder'
require_relative 'settings'
require_relative 'string_extensions'

# Represents a team member, a person assigned to a team
# @attr_reader [String] team the name of the team the person belongs to
# @attr_reader [String] first the first name of the team member
# @attr_reader [String] last the last name of the team member
class Employee
  include Comparable
  extend EmployeeFinder
  using StringExtensions

  attr_reader :team, :first, :last

  # Create a new Employee object
  #
  # @param [Hash] params the employee data
  def initialize(**params)
    @team = params.fetch(:team)
    @first = params.fetch(:first)
    @last = params.fetch(:last)

    raise ArgumentError, 'Team must not be empty' if team.to_s.empty?
    raise ArgumentError, 'First name must not be empty' if first.to_s.empty?
    raise ArgumentError, 'Last name must not be empty' if last.to_s.empty?
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

  # Object equality by its fields
  #
  # @param [Type] other the object to compare
  # @return [Boolean] whether the object is equivalent
  def eql?(other)
    return unless other.respond_to?(:team) && other.respond_to?(:first) && other.respond_to?(:last)

    (self <=> other).zero?
  end

  # Object equality
  def ==(other)
    eql?(other)
  end

  # Object comparison by its fields
  #
  # @param [Type] other the object to compare
  # @return [Integer] -1 (other less than), 0 (equal), or 1 (greater than)
  def <=>(other)
    comparison = team <=> other.team
    comparison = first <=> other.first if comparison.zero?
    comparison = last <=> other.last if comparison.zero?
    comparison
  end

  # The name used in folder creation
  # @return [String] the folder name
  def canonical_name
    first_name, last_name = [first, last].map{ |n| n.tr(' ','-').strip_nonalnum }
    "#{first_name}-#{last_name}".unidowncase
  end

  # The display name, in title case
  # @return [String] the display name
  def to_s
    "#{first} #{last}".to_name
  end
end
