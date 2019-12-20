# frozen_string_literal: true

require 'highline/import'
require 'settingslogic'

# Application-wide settings
class Settings < Settingslogic
  class << self
    # the top folder for content
    # @note hard-coded so application can bootstrap itself
    def root
      'data'
    end

    # the location of the configuration file
    def config_file
      File.join(root, 'config.yml')
    end

    # provides an interview for console interaction
    def console
      @console ||= set_console
      @console
    end

    # set up a new HighLine input and output stream
    def set_console(input = $stdin, output = $stdout)
      @console = HighLine.new(input, output)
    end

    # allows stubbing of user input, including just hitting return
    #   to accept defaults
    # HACK: regular RSpec mocking with allow() works in cases where
    #   input is needed, but doesn't when hitting return is desired.
    #   This is needed to test defaults. Figure out how to mock 
    #   Highline to just hit return and this method is no longer
    #   necessary.
    def with_mock_input(*input)
      input_stream = StringIO.new(input.join)
      @console = HighLine.new(input_stream, StringIO.new)
      yield
    ensure
      @console = HighLine.new($stdin, $stdout)
    end

    # a template for the default configuration
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
          meeting_location_default: alcove
          log_filename: log.adoc
          overview_filename: overview.adoc
          pto_default: vacation
          voip_meeting_default: Zoom

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
