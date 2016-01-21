require 'pathname'
require 'facets/string/titlecase'
require_relative 'employee_file'
require_relative 'employee_folder'

class Team
  attr_reader :team

  def initialize(params = {})
    @team = params[:team]
    # @first = params[:first]
    # @last = params[:last]
    #puts "created employee, first: #{first}, last: #{last} on #{team}"
  end

  # consolidate with gen-overview-files?
  def self.split_path(path)
      Pathname(path).each_filename.to_a
  end

  def self.parse_dir(dir)
    paths = split_path dir
    root, team = paths
    #name = name.gsub!('-', ' ').titlecase.strip.split(/\s+/)
    # first = name[0]
    # last = name[1]
    {team: team}
  end

  def self.find(key)
    root = EmployeeFolder.root
    puts "FIND: Searching in #{root}"
    Dir.glob("#{root}/*") do |d|
      puts "FIND: Searching #{d}"
      next unless Dir.exist? d
      if /#{key}/ =~ d.to_s
        team = parse_dir d
        return Team.new team
      end
    end
  end

  def members
    result = []
    root = EmployeeFolder.root
    Dir.glob("#{root}/#{team}/*") do |d|
        employee = Employee.parse_dir d
        result << Employee.new(employee)
    end
    result
  end

  def to_s
    "#{@team.capitalize}"
  end
end
