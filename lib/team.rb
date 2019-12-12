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
  def initialize(**params)
    @team = params.fetch(:team).to_path
  end

  # @!method Get an array of team members folders located in this folder
  def members_by_folder
    Dir.glob("#{EmployeeFolder.root}/#{team}/*")
  end

  # @!method Get an array of team members, based on folder location
  def members
    members_by_folder.map do |folder|
      member_spec = Employee.parse_dir folder
      Employee.new member_spec
    end
  end

  def path
    team
  end

  def split_path
    to_s.split_path
  end

  # @!method Represent a Team by its titlecased name
  def to_s
    team.path_to_name
  end

  # @!method Teams are equal if the have the same #team value
  def eql?(other)
    return false unless other.respond_to? :team

    team.eql? other.team
  end

  # @!method Equality operator overload
  def ==(other)
    eql? other
  end
end
