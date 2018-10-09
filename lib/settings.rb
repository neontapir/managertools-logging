# frozen_string_literal: true

require 'highline/import'
require 'settingslogic'

# Application-wide settings
class Settings < Settingslogic
  def self.root
    'data'
  end

  def self.config_file
    File.join(root, 'config.yml')
  end

  def self.console
    @console ||= set_console
    @console
  end

  def self.set_console(input = STDIN, output = STDOUT)
    @console = HighLine.new(input, output)
  end

  def self.with_mock_input(input = '')
    begin
      input_stream = input.empty? ? StringIO.new : StringIO.new(input)
      @console = HighLine.new(input_stream, StringIO.new)
      yield
    ensure
      @console = HighLine.new(STDIN, STDOUT)
    end
  end

  def self.default_config
    <<~CONFIG
      defaults: &defaults
        # root is set in lib/settings.rb
        root: data
        candidates_root: zzz_candidates
        departed_root: zzz_departed

      development:
        <<: *defaults

      test:
        <<: *defaults

      production:
        <<: *defaults
    CONFIG
  end

  unless File.exist? config_file
    warn "File not found at #{config_file}, either MT not set up or executing from wrong folder"
  end
  source config_file
  namespace 'production' # Rails.env
end
