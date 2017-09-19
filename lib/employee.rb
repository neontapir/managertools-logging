# frozen_string_literal: true

require 'facets/string/titlecase'

require_relative 'employee_finder'
require_relative 'employee_folder'
require_relative 'mt_data_formatter'
require_relative 'path_splitter'

# Represents a team member, a person assigned to a team
# @attr_reader [String] team the name of the team the person belongs to
# @attr_reader [String] first the first name of the team member
# @attr_reader [String] last the last name of the team member
class Employee
  extend EmployeeFinder
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

  # Get the LogFile for the employee
  #
  # @return [LogFile] the employee's log file
  def file
    folder = EmployeeFolder.new self
    LogFile.new folder
  end

  # Object equality by its fields
  #
  # @param [Type] other the object to compare
  # @return [Boolean] whether the object is equivalent
  def eql?(other)
    return unless other.respond_to?(:team) && other.respond_to?(:first) && other.respond_to?(:last)
    team.eql?(other.team) && first.eql?(other.first) && last.eql?(other.last)
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
