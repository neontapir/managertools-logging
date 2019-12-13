# frozen_string_literal: true

require 'highline'
require_relative '../settings'

# Create default config file
class InitCommand
  # @!method command(arguments, options)
  #   Create a default config file in the configured location
  def command(_, _ = nil)
    config_file = Settings.config_file
    if File.exist?(config_file)
      warn HighLine.color("Aborting, config file #{config_file} already exists", :red)
    else
      FileUtils.mkdir_p(Settings.root)
      IO.write(config_file, Settings.default_config)
      raise IOError, "Failed to create settings file #{config_file}" unless File.exist? config_file

      puts "Initializing MT, created #{config_file}"
    end
  end
end
