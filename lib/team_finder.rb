# frozen_string_literal: true

require 'pathname'

require_relative 'employee_folder'
require_relative 'log_file'
require_relative 'string_extensions'
require_relative 'path_string_extensions'
require_relative 'settings'

# For reporting searches with no results
class TeamNotFoundError < StandardError
end

# Represents a team search provider
module TeamFinder
  include PathStringExtensions
  using PathStringExtensions

  # Parse the path as though it is an team spec and return the result
  #
  # @param [String] dir the location of a person
  # @return [Hash] the team data represented by the location
  def parse_dir(dir)
    # TEMPORARY 20191212
    _root, team = dir.split_path
    { team: team }
  end

  # Given a part of team data, find the first matching team
  #
  # @param [String] key the lookup data needed to find the team
  # @return [Team] a Team object
  def find(key)
    target = key.to_path
    Dir.glob("#{EmployeeFolder.root}/*") do |dir|
      next unless Dir.exist? dir
      next unless dir[target]

      team_spec = parse_dir dir
      return Team.new team_spec
    end
  end
end
