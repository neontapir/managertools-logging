# frozen_string_literal: true

require 'fileutils'
require_relative 'mt_data_formatter'
require_relative 'path_formatter'
require_relative 'settings'

# Reparesents a folder that contains files about a direct report
# @attr_reader [Project] project the project whose data resides in the folder
class ProjectFolder
  include MtDataFormatter
  include PathFormatter

  attr_reader :project

  class << self
    # The root folder where data is stored, taken from Settings
    def root
      Settings.root
    end
  end

  # Create a new ProjectFolder object
  def initialize(project)
    @project = project
  end

  # The canonical name of the folder
  def folder_name
    project_name = project.project.strip_nonalnum
    unidown "#{project_name}"
  end

  # The path to the file, relative to the parent folder of the root
  def path
    File.join(Settings.root, Settings.project_root, to_path_string(folder_name))
  end

  # Create a file system folder at path
  def create
    FileUtils.mkdir_p path
  end

  # Make sure a file system folder exists at the path
  def ensure_exists
    create unless Dir.exist? path
  end

  # The string representation
  # @return the path
  def to_s
    path
  end
end
