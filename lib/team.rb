require 'facets/string/titlecase'

require_relative 'employee'
require_relative 'employee_folder'
require_relative 'path_splitter'

# Represents a delivery team
# @!attribute [r] team
#   @return [String] the path name of the team
class Team
  attr_reader :team

  extend PathSplitter

  # Create a new Team object
  # @param [Hash] params a Hash with a :team entry
  def initialize(**params)
    team = params.fetch(:team).downcase
    team.tr!(' ', '-') if team.include? ' '
    @team = team
  end

  # Extract the team section of a path
  def self.parse_dir(dir)
    paths = split_path dir
    _root, team = paths
    { team: team }
  end

  # Find the first matching folder and return a corresponding team object
  def self.find(key)
    folder = Dir.glob("#{EmployeeFolder.root}/*").find { |f| folder_matches?(f, key) }
    return if folder.nil?
    team = parse_dir folder
    Team.new team
  end

  # Determine if a folder matches the given string
  def self.folder_matches?(folder, key)
    (Dir.exist? folder) && (/#{key}/ =~ folder.to_s)
  end

  # Convert a path string to a titlecased name
  def self.to_name(input)
    input = input.tr('-', ' ') if input.include? '-'
    input.titlecase
  end

  # Convert a titlecased string to a path name
  def self.to_path_string(input)
    input = input.tr(' ', '-') if input.include? ' '
    input.downcase
  end

  # Get an array of team members folders located in this folder
  def members_by_folder
    Dir.glob("#{EmployeeFolder.root}/#{Team.to_path_string(team)}/*")
  end

  # Get an array of team members, based on folder location
  def members
    members_by_folder.map { |folder| Employee.new(Employee.parse_dir(folder)) }
  end

  # Represent a Team by its titlecased name
  def to_s
    Team.to_name(team)
  end

  # Teams are equal if the have the same #team value
  def eql?(other)
    team == other.team if other.respond_to?(:team)
  end

  # Equality operator overload
  def ==(other)
    eql?(other)
  end
end
