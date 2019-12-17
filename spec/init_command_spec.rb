# frozen_string_literal: true

require './lib/commands/init_command'
require_relative 'settings_helper'

RSpec.describe InitCommand do
  subject(:init_command) { InitCommand.new }
  
  it 'will warn and abort if config file exists' do
    Settings.with_mock_input do
      expect{ init_command.command }.to output(/already exists/).to_stderr
    end
  end

  it 'will initialize the data structure if config file missing' do
    test_location = 'my_temp_location'
    begin
      FileUtils.rm_r test_location if Dir.exist? test_location
      FileUtils.mv Settings.root, test_location
      Settings.with_mock_input do
        expect{ init_command.command }.to output(/Initializing MT/).to_stdout
        remove_test_settings_file
      end
    rescue
      FileUtils.mv test_location, Settings.root  
    ensure
      FileUtils.rm_r test_location if Dir.exist? test_location
    end
  end
end