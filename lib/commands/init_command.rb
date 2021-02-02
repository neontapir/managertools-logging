# frozen_string_literal: true

require 'highline'
require_relative 'mt_command'
require_relative '../settings'

# Create default config file
class InitCommand < MtCommand
  attr_reader :settings

  def initialize(settings = Settings)
    @settings = settings
    super()
  end

  # command(arguments, options)
  #   Create a default config file in the location given by settings
  def command(_ = nil, _ = nil)
    config_file = settings.config_file
    if File.exist?(config_file)
      warn HighLine.color("Aborting, config file #{config_file} already exists", :red)
    else
      FileUtils.mkdir_p(settings.root)
      IO.write(config_file, settings.default_config)
      raise IOError, "Failed to create settings file #{config_file}" unless File.exist? config_file

      puts "Initializing MT, created #{config_file}"
    end
  end
end
