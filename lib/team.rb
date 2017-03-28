require 'facets/string/titlecase'

require_relative 'employee'
require_relative 'employee_folder'
require_relative 'path_splitter'

# Represents a delivery team
class Team
  attr_reader :team

  extend PathSplitter

  def initialize(**params)
    team = params.fetch(:team).downcase
    team.tr!(' ', '-') if team.include? ' '
    @team = team
  end

  def self.parse_dir(dir)
    paths = split_path dir
    _root, team = paths
    { team: team }
  end

  def self.find(key)
    folder = Dir.glob("#{EmployeeFolder.root}/*").find { |f| folder_matches?(f, key) }
    return if folder.nil?
    team = parse_dir folder
    Team.new team
  end

  def self.folder_matches?(f, key)
    (Dir.exist? f) && (/#{key}/ =~ f.to_s)
  end

  def self.to_name(input)
    input = input.tr('-', ' ') if input.include? '-'
    input.titlecase
  end

  def self.to_path_string(input)
    input = input.tr(' ', '-') if input.include? ' '
    input.downcase
  end

  def members_by_folder
    Dir.glob("#{EmployeeFolder.root}/#{Team.to_path_string(team)}/*")
  end

  def members
    members_by_folder.map { |folder| Employee.new(Employee.parse_dir(folder)) }
  end

  def to_s
    Team.to_name(team)
  end

  def eql?(other)
    team == other.team if other.respond_to?(:team)
  end

  def ==(other)
    eql?(other)
  end
end
