# frozen_string_literal: true

require 'attr_extras'
require 'fileutils'
require_relative 'string_extensions'
require_relative 'path_string_extensions'
require_relative 'settings'

# Reparesents a folder that contains files about a team
# @attr_reader [Team] team the project whose data resides in the folder
class TeamFolder
  using StringExtensions
  using PathStringExtensions

  attr_value_initialize :team

  class << self
    # The root folder where data is stored, taken from Settings
    def root
      Settings.root
    end
  end

  # The canonical name of the folder
  def folder_name
    team_name = team.team.tr(' ', '-').strip_nonalnum
    team_name.unidowncase
  end

  # The path to the file, relative to the parent folder of the root
  def path
    File.join(Settings.root, folder_name.to_path)
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