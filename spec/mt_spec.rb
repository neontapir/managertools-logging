# frozen_string_literal: true

MT = File.expand_path('../../mt', __FILE__)
load MT

require 'spec_helper'
require 'settings_helper'

RSpec.describe 'mt script', type: [:aruba, :slow] do
  before(:each) do
    create_test_settings_file(Aruba.config.working_directory)
  end

  context 'without arguments' do
    let(:command) do 
      run_command_and_stop("ruby #{MT}", fail_on_error: false)
    end

    it 'finds the script' do
      expect(File.exist? MT).to be_truthy
    end

    it 'finds the data file' do
      expect(Aruba.config.working_directory).to eq 'tmp/aruba'
      expect(Dir.exist? "#{Aruba.config.working_directory}/data").to be_truthy
      expect(File.exist? "#{Aruba.config.working_directory}/data/config.yml").to be_truthy
    end

    it 'prints an error' do
      command
      expect(last_command_started).not_to be_successfully_executed
      expect(last_command_started.stderr).to eq("invalid command. Use --help for more information\r\n")
    end
  end

  context 'with help flag' do
    let(:command) do 
      run_command_and_stop("ruby #{MT} --help", fail_on_error: false)
    end

    it 'prints help' do
      command
      expect(last_command_started).to be_successfully_executed
      expect(last_command_started.stdout).to match(/NAME.*:/)
      expect(last_command_started.stdout).to match(/DESCRIPTION.*:/)
      expect(last_command_started.stdout).to match(/COMMANDS.*:/)
      expect(last_command_started.stdout).to match(/GLOBAL OPTIONS.*:/)
      expect(last_command_started.stdout).to match(/ALIASES.*:/)
    end
  end
end
