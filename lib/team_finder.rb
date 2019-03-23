# frozen_string_literal: true

require 'pathname'

require_relative 'employee_folder'
require_relative 'log_file'
require_relative 'mt_data_formatter'
require_relative 'path_formatter'
require_relative 'settings'

# Represents a team search provider
module TeamFinder
  include PathFormatter

  # Parse the path as though it is an team spec and return the result
  #
  # @param [String] dir the location of a person
  # @return [Hash] the team data represented by the location
  def parse_dir(dir)
    paths = split_path dir
    _root, team = paths
    { team: team }
  end

  # Given a part of team data, find the first matching team
  #
  # @param [String] key the lookup data needed to find the team
  # @return [Team] a Team object
  def find(key)
    root = EmployeeFolder.root
    target = to_path_string key
    Dir.glob("#{root}/*") do |d|
      next unless Dir.exist? d
      if /#{target}/ =~ d.to_s
        team_spec = parse_dir d
        return Team.new team_spec
      end
    end
  end
end
