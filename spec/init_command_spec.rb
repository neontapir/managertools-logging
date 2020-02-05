# frozen_string_literal: true

require './lib/commands/init_command'
require_relative 'settings_helper'

RSpec.describe InitCommand do
  subject(:init_command) { InitCommand.new }

  context 'config file exists' do
    it 'will warn and abort' do
      expect { init_command.command }.to output(/already exists/).to_stderr
    end
  end

  context 'config file does not exist' do
    before :all do
      class Settings
        class << self
          undef :fake_root if method_defined? :fake_root
          def fake_root
            'test_init_command'
          end

          alias_method :real_root, :root
          alias_method :root, :fake_root
        end
      end
    end

    after :all do
      class Settings
        class << self
          alias_method :root, :real_root
        end
      end
    end

    it 'will initialize the data structure' do
      config_file = Settings.config_file
      expect(File.exist?(config_file)).to be_falsey
      expect { init_command.command }.to output(/Initializing MT/).to_stdout.and output('').to_stderr
      expect(File.exist?(config_file)).to be_truthy
      FileUtils.rm_r config_file
      expect(File.exist?(config_file)).to be_falsey
    end
  end
end
