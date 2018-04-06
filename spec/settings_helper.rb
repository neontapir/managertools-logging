# frozen_string_literal: true

require './lib/settings.rb'

# Help with Settings during tests by creating a default configuration file
module SettingsHelper
  
  def config_file
    Settings.config_file
  end
  
  def create_test_settings_file
    config_file = Settings.config_file
    FileUtils.mkdir_p(Settings.root)
    IO.write(config_file, Settings.default_config)
    raise IOError, "Missing settings file #{config_file}" unless File.exist? config_file
    Settings.reload!
  end

  def remove_test_settings_file
    File.delete config_file if File.exist? config_file
  end
end
