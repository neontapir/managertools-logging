# frozen_string_literal: true

require 'attr_extras'
require_relative 'path_string_extensions'
require_relative 'project_finder'
require_relative 'project_folder'

# Represents a sofware project
#   @!attribute [r] project
#   @return [String] the path name of the project
class Project
  attr_value :project

  using PathStringExtensions
  extend ProjectFinder

  # Create a new Project object
  # @param [String] project a project name
  def initialize(project:)
    raise ArgumentError, 'Name must not be empty' if project.to_s.empty?

    @project = project.to_path
  end

  # the path to the project's files
  def path
    project
  end

  # Get the LogFile for the project
  #
  # @return [LogFile] the project's log file
  def file
    folder = ProjectFolder.new self
    LogFile.new folder
  end

  # convenience method for splitting a path
  def split_path
    to_s.split_path
  end

  # Represent a Project by its titlecased name
  def to_s
    project.path_to_name
  end
end
