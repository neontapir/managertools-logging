# frozen_string_literal: true

require './lib/settings'

# Help with Settings during tests by creating a default configuration file
module SettingsHelper
  attr_reader :config_file

  def create_test_settings_file(parent = '.')
    remove_test_settings_file
    @config_file = File.join parent, Settings.config_file
    FileUtils.mkdir_p(File.join(parent, Settings.root))
    IO.write(@config_file, Settings.default_config)
    raise IOError, "Missing settings file #{config_file}" unless File.exist? config_file

    Settings.reload!
  end

  # FIXME: When running partial test suites, this can fail due to a permissions issue
  def remove_test_settings_file
    File.delete config_file if (config_file && File.exist?(config_file))
  rescue => e
    warn "Unable to remove test settings file, #{e}"
  end
end
