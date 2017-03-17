require 'pathname'
require 'facets/string/titlecase'
require 'require_all'
require_rel '.'

# Represents a delivery team
class Team
  attr_reader :team

  extend PathSplitter

  def initialize(**params)
    @team = params[:team].capitalize
  end

  def self.parse_dir(dir)
    paths = split_path dir
    _root, team = paths
    { team: team }
  end

  def self.find(key)
    Dir.glob("#{EmployeeFolder.root}/*") do |folder|
      next unless Dir.exist? folder
      if /#{key}/ =~ folder.to_s
        team = parse_dir folder
        return Team.new team
      end
    end
  end

  def members_by_folder
    Dir.glob("#{EmployeeFolder.root}/#{team}/*")
  end

  def members
    members_by_folder.map do |folder|
      Employee.new(Employee.parse_dir(folder))
    end
  end

  def ==(other)
    @team == other.team
  end

  def to_s
    @team.capitalize
  end
end
