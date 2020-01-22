# frozen_string_literal: true

require_relative 'employee'
require_relative 'employee_folder'
require_relative 'path_string_extensions'
require_relative 'team_finder'

# Represents a delivery team
#   @!attribute [r] team
#   @return [String] the path name of the team
class Team
  attr_reader :team

  using PathStringExtensions
  extend TeamFinder

  # Create a new Team object
  # @param [Hash] params a Hash with a :team entry
  def initialize(team:)
    raise ArgumentError, 'Name must not be empty' if team.to_s.empty?

    @team = team.to_path
  end

  # Get an array of team members folders located in this folder
  def members_by_folder
    Dir.glob("#{EmployeeFolder.root}/#{team}/*")
  end

  # Get an array of team members, based on folder location
  def members
    members_by_folder.map do |folder|
      member_spec = Employee.parse_dir folder
      member_spec.to_employee
    end
  end

  # Return a suitable string used for the team's filesystem folder
  def path
    team
  end

  # Represent a Team by its titlecased name
  def to_s
    team.path_to_name
  end

  # Teams are equal if the have the same #team value
  def ==(other)
    return false unless other.respond_to? :team

    team.eql? other.team
  end

  # Equality operator overload  
  def eql?(other)
    instance_of?(other.class) && self == other
  end
end
