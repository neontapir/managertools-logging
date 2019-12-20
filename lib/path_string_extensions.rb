# frozen_string_literal: true

require 'namecase'

# Splits path into team and member name components
module PathStringExtensions
  refine Dir do
    # Turn a relative path into an array of folders and the filename
    #
    # @example Parsing a path
    #  Dir.new('foo/bar/baz.txt').split_path #=> ['foo', 'bar', 'baz.txt']
    # @raise [ArgumentError] if path empty
    def split_path
      raise ArgumentError, 'Empty path' unless self

      Pathname.new(self).each_filename.to_a
    end
  end

  refine String do
    # Turn a relative path into an array of folders and the filename
    #
    # @example Parsing a path
    #  'foo/bar/baz.txt'.split_path #=> ['foo', 'bar', 'baz.txt']
    # @raise [ArgumentError] if path empty
    def split_path
      raise ArgumentError, 'Empty path' unless self

      Pathname.new(self).each_filename.to_a
    end

    # Convert a titlecased string to a path name
    def to_path
      tr(' ', '-').downcase
    end

    # Convert a path string to a title-cased name
    # Name case is needed for proper names
    # Titlecase is needed because name case doesn't handle prepositions,
    #   which are sometimes found in team names
    def path_to_name
      # tr('-', ' ').titlecase
      NameCase(tr('-', ' ').upcase).titlecase
    end
  end
end
