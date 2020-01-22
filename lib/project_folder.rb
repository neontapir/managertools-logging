# frozen_string_literal: true

require 'attr_extras'
require 'fileutils'
require_relative 'string_extensions'
require_relative 'path_string_extensions'
require_relative 'settings'

# Reparesents a folder that contains files about a project
# @attr_reader [Project] project the project whose data resides in the folder
class ProjectFolder
  using StringExtensions
  using PathStringExtensions

  attr_value_initialize :project

  class << self
    # The root folder where data is stored, taken from Settings
    def root
      File.join(Settings.root, Settings.project_root)
    end
  end

  # The canonical name of the folder
  def folder_name
    project_name = project.project.tr(' ', '-').strip_nonalnum
    project_name.unidowncase
  end

  # The path to the file, relative to the parent folder of the root
  def path
    File.join(ProjectFolder.root, folder_name.to_path)
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
