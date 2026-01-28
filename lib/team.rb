# frozen_string_literal: true

require 'attr_extras'
require_relative 'employee'
require_relative 'employee_folder'
require_relative 'path_string_extensions'
require_relative 'team_finder'

# Represents a delivery team
# @!attribute [r] team
# @return [String] the path name of the team
class Team
  using PathStringExtensions
  extend TeamFinder

  # Create a new Team object
  # @param [String] team a team name
  def initialize(team:)
    raise ArgumentError, 'Name must not be empty' if team.to_s.empty?
    @team = team.to_path
  end

# Get an array of team members, based on folder location
  def members
    result = []
    Dir.glob("#{EmployeeFolder.root}/#{team}/*").each do |folder|
      employee_spec = Employee.parse_dir folder
      # Skip team folders that failed to parse as employees
      next unless employee_spec.first && employee_spec.last
      
      result << employee_spec
    end
    result
  end
    end
  end

  # Return a suitable string used for the team's filesystem folder
  def path
    @team
  end

  # Represent a Team by its titlecased name
  def to_s
    team.path_to_name
  end

  # Teams are equal if their paths are the same
  def eql?(other)
    other.respond_to?(:team) && team.eql?(other.team)
  end
end