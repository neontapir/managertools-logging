# frozen_string_literal: true

require './lib/commands/init_command'
require_relative 'settings_helper'

RSpec.describe InitCommand do
  subject(:init_command) { described_class.new }

  context 'when config file exists' do
    it 'will warn and abort' do
      expect { init_command.command }.to output(/already exists/).to_stderr
    end
  end

  context 'when config file does not exist' do
    let(:fake_settings) do
      Class.new(Settings) do
        def self.root
          'test_init_command'
        end
      end
    end

    let(:config_file) { fake_settings.config_file }

    before do
      expect(File).not_to exist config_file
    end

    after do
      temp_folder = File.dirname(config_file)
      FileUtils.rm_r temp_folder
      expect(Dir).not_to exist temp_folder
    end

    it 'will initialize the data structure' do
      expect { described_class.new(fake_settings).command }.to output(/Initializing MT/).to_stdout.and output('').to_stderr
      expect(File).to exist config_file
    end
  end
end
