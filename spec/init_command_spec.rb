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
    class FakeSettings < Settings
      def self.root
        'test_init_command'
      end
    end

    config_file = FakeSettings.config_file

    before do
      expect(File).not_to exist config_file
    end

    after do
      FileUtils.rm_r File.dirname(config_file)
      expect(File).not_to exist config_file
    end

    it 'will initialize the data structure' do
      expect { InitCommand.new(FakeSettings).command }.to output(/Initializing MT/).to_stdout.and output('').to_stderr
      expect(File).to exist config_file
    end
  end
end
