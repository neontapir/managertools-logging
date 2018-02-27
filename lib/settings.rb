# frozen_string_literal: true

require 'highline/import'
require 'settingslogic'

# Application-wide settings
class Settings < Settingslogic
  def self.root
    'data'
  end

  def self.console
    @console ||= HighLine.new(STDIN, STDOUT)
    @console
  end

  def self.set_console(input = STDIN, output = STDOUT)
    @console = HighLine.new(input, output)
  end

  config_file = "#{Settings.root}/config.yml"
  unless File.exist? config_file
    raise "No file at #{config_file}, either MT not set up or executing from wrong folder"
  end
  source config_file
  namespace 'production' # Rails.env
end
