# frozen_string_literal: true

require './lib/commands/init_command'
require_relative 'settings_helper'

RSpec.describe InitCommand do
  subject(:init_command) { InitCommand.new }

  context 'config file exists' do
    it 'will warn and abort' do
      Settings.with_mock_input do
        expect { init_command.command }.to output(/already exists/).to_stderr
      end
    end
  end

  context 'config file exists' do
    let(:test_location) { 'data_temp_location' }

    it 'will initialize the data structure' do
      FileUtils.rm_r test_location if Dir.exist? test_location
      FileUtils.mv Settings.root, test_location
      Settings.with_mock_input do
        expect { init_command.command }.to output(/Initializing MT/).to_stdout
        remove_test_settings_file
      end
    rescue
      FileUtils.mv test_location, Settings.root
    ensure
      FileUtils.rm_r test_location if Dir.exist? test_location
    end
  end
end
