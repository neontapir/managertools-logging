# frozen_string_literal: true

require 'attr_extras'
require 'fileutils'

# Basic file utilities
module MtFile
  attr_implement :path

  # @abstract Ensure a file exists
  def ensure_exists
    FileUtils.mkdir_p File.dirname(path)
    FileUtils.touch path
  end

  # @abstract create a temporary write location of the file
  def make_backup
    ensure_exists
    FileUtils.copy(path, backup)
  end

  # @abstract remove the temporary write location of the file
  def remove_backup
    FileUtils.rm_r backup if File.exist? backup
  end

  # @abstract returns the temporary write location of the file
  # Note: I thought about Tempfile for this, but it broke some tests.
  def backup
    path + '.bak'
  end

  # # @abstract returns the file system location of the file
  # def path
  #   raise NotImplementedError, 'A MtFile must define its #path'
  # end

  # Represent the file as its filesystem location
  def to_s
    path
  end
end
