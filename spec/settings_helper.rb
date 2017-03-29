require './lib/settings.rb'

module SettingsHelper
  def config_file
    File.join(Settings.root, 'config.yml')
  end

  def create_test_settings_file
    doc = <<-EOF
      defaults: &defaults
        # root is set in lib/settings.rb
        candidates_root: zzz_candidates
        departed_root: zzz_departed # not used yet

      development:
        <<: *defaults

      test:
        <<: *defaults

      production:
        <<: *defaults
    EOF

    FileUtils.mkdir_p(Settings.root)
    IO.write(config_file, doc)
    raise IOError, "Missing settings file #{config_file}" unless File.exist? config_file
  end

  def remove_test_settings_file
    File.delete config_file if File.exist? config_file
  end
end
