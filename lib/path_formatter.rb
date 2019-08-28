# frozen_string_literal: true

require 'namecase'
require_relative 'mt_data_formatter'

# Splits path into team and member name components
module PathFormatter
  include MtDataFormatter
  # Turn a relative path into an array of folders and the filename
  #
  # @example Parsing a path
  #  split_path('foo/bar/baz.txt') #=> ['foo', 'bar', 'baz.txt']
  # @raise [ArgumentError] if path empty
  def split_path(path)
    raise ArgumentError, 'Empty path' unless path

    Pathname.new(path).each_filename.to_a
  end

  # Determine if a path matches the given string
  #
  # @param [string] path the folder to search
  # @param [string] key the substring to search for
  # @raise [ArgumentError] if path empty
  def matches?(path, key)
    raise ArgumentError, 'Empty path' unless path

    Dir.exist?(path) && path[key]
  end

  # Convert a titlecased string to a path name
  def to_path_string(input)
    input.tr(' ', '-').downcase
  end

  # Convert a path string to a titlecased name
  def path_to_name(input)
    input.tr('-', ' ').titlecase
  end
end
