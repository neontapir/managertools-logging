require 'pathname'
require 'facets/string/titlecase'
require 'require_all'
require_rel '.'

# Represents a team member
class Employee
  extend MtDataFormatter
  extend PathSplitter

  attr_reader :team, :first, :last

  def initialize(**params)
    @team = params[:team]
    @first = params[:first]
    @last = params[:last]
    #puts "DEBUG: created employee, first: '#{first}', last: '#{last}' on '#{team}'"
  end

  def self.parse_dir(dir)
    paths = split_path dir
    _root, team, name = paths
    name = name.tr!('-', ' ').titlecase.strip.split(/\s+/)
    first = name[0]
    last = name[1]
    { team: team, first: first, last: last }
  end

  def self.find(key)
    root = EmployeeFolder.root
    Dir.glob("#{root}/*/*") do |d|
      next unless Dir.exist? d
      if /#{key}/ =~ d.to_s
        employee = parse_dir d
        return Employee.new employee
      end
    end
  end

  def ==(other)
    @team == other.team && @first == other.first && @last == other.last
  end

  def canonical_name
    unidown "#{@first}-#{@last}"
  end

  def to_s
    "#{@first.capitalize} #{@last.capitalize}"
  end
end
