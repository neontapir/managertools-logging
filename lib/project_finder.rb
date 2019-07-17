# frozen_string_literal: true

require 'pathname'

require_relative 'log_file'
require_relative 'mt_data_formatter'
require_relative 'path_formatter'
require_relative 'settings'

# For reporting searches with no results
class ProjectNotFoundError < StandardError
end

# Represents a project search provider
module ProjectFinder
  include PathFormatter

  # Parse the path as though it is an project spec and return the result
  #
  # @param [String] dir the location of a person
  # @return [Hash] the project data represented by the location
  def parse_dir(dir)
    paths = split_path dir
    project = paths.last
    { project: project }
  end

  # Given a part of project data, find the first matching project
  #
  # @param [String] key the lookup data needed to find the project
  # @return [Project] a Project object
  def find(key)
    target = to_path_string key
    project_root = File.join(Settings.root, Settings.project_root)
    Dir.glob("#{project_root}/*") do |dir|
      next unless Dir.exist? dir
      next unless dir[target]

      project_spec = parse_dir dir
      return Project.new project_spec
    end
  end
end
