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

    File.open(config_file, 'w') {|f| f.write(doc) } unless File.exist? config_file
    raise IOError, "Missing settings file #{config_file}" unless File.exist? config_file
  end

  def remove_test_settings_file
    File.delete config_file if File.exist? config_file
  end
end
