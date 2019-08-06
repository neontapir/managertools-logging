# frozen_string_literal: true

require 'highline/import'
require 'settingslogic'

# Application-wide settings
class Settings < Settingslogic
  class << self
    def root
      'data'
    end

    def config_file
      File.join(root, 'config.yml')
    end

    def console
      @console ||= set_console
      @console
    end

    def set_console(input = $stdin, output = $stdout)
      @console = HighLine.new(input, output)
    end

    # HACK: regular RSpec mocking with allow() works in cases where
    #   input is needed, but doesn't when hitting return is desired.
    #   Figure out how to mock Highline to just hit return and this
    #   method is no longer necessary.
    def with_mock_input(input = '')
      input_stream = input.empty? ? StringIO.new : StringIO.new(input)
      @console = HighLine.new(input_stream, StringIO.new)
      yield
    ensure
      @console = HighLine.new($stdin, $stdout)
    end

    def default_config
      <<~CONFIG
        defaults: &defaults
          # TODO: root is set in lib/settings.rb
          root: data
          candidates_root: zzz_candidates
          departed_root: zzz_departed
          project_root: projects
          editor: atom
          feedback_polarity_default: positive
          location_default: alcove
          pto_default: vacation

        development:
          <<: *defaults

        test:
          <<: *defaults

        production:
          <<: *defaults
      CONFIG
    end
  end

  source config_file
  namespace 'production' # Rails.env
end
