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
    root = EmployeeFolder.root
    # puts "FIND: Searching in #{root}"
    Dir.glob("#{root}/*") do |d|
      # puts "FIND: Searching #{d}"
      next unless Dir.exist? d
      if /#{key}/ =~ d.to_s
        team = parse_dir d
        return Team.new team
      end
    end
  end

  def members_by_folder
    result = []
    root = EmployeeFolder.root
    Dir.glob("#{root}/#{team}/*") do |d|
      result << d
    end
    result
  end

  def members
    result = []
    members_by_folder.each do |d|
      employee_data = Employee.parse_dir d
      result << Employee.new(employee_data)
    end
    result
  end

  def ==(other)
    @team == other.team
  end

  def to_s
    @team.capitalize
  end
end
