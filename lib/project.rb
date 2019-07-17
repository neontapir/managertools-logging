# frozen_string_literal: true

require_relative 'path_formatter'
require_relative 'project_finder'
require_relative 'project_folder'

# Represents a sofware project
#   @!attribute [r] project
#   @return [String] the path name of the project
class Project
  attr_reader :project

  include PathFormatter
  extend ProjectFinder

  # Create a new Project object
  # @param [Hash] params a Hash with a :project entry
  def initialize(**params)
    @project = to_path_string params.fetch(:project)
  end

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

  # @!method Represent a Project by its titlecased name
  def to_s
    path_to_name(project)
  end

  # @!method Projects are equal if the have the same #project value
  def eql?(other)
    return false unless other.respond_to? :project

    project.eql? other.project
  end

  # @!method Equality operator overload
  def ==(other)
    eql? other
  end
end
