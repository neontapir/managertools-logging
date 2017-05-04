require 'facets/string/titlecase'

require_relative 'employee'
require_relative 'employee_finder'
require_relative 'employee_folder'
require_relative 'path_splitter'

# Represents a delivery team
# @!attribute [r] team
#   @return [String] the path name of the team
class Team
  attr_reader :team

  extend EmployeeFinder
  extend PathSplitter

  # Create a new Team object
  # @param [Hash] params a Hash with a :team entry
  def initialize(**params)
    @team = Team.to_path_string(params.fetch(:team))
  end

  # Convert a path string to a titlecased name
  def self.to_name(input)
    input.tr('-', ' ').titlecase
  end

  # Convert a titlecased string to a path name
  def self.to_path_string(input)
    input.tr(' ', '-').downcase
  end

  # Get an array of team members folders located in this folder
  def members_by_folder
    Dir.glob("#{EmployeeFolder.root}/#{team}/*")
  end

  # Get an array of team members, based on folder location
  def members
    members_by_folder.map do |folder|
      member_spec = Team.parse_dir folder
      Employee.new(member_spec)
    end
  end

  # Represent a Team by its titlecased name
  def to_s
    Team.to_name(team)
  end

  # Teams are equal if the have the same #team value
  def eql?(other)
    return false unless other.respond_to?(:team)
    team.eql?(other.team)
  end

  # Equality operator overload
  def ==(other)
    eql?(other)
  end
end
