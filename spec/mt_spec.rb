# frozen_string_literal: true

unless defined? MT
  MT = File.expand_path('../mt', __FILE__)
  load MT
end

require 'spec_helper'
require 'settings_helper'

RSpec.describe 'mt script', type: [:aruba, :slow] do
  before(:each) do
    create_test_settings_file(Aruba.config.working_directory)
  end

  context 'without arguments' do
    let(:command) do
      run_command_and_stop("#{MT}")
    end

    it 'finds the script' do
      expect(File.exist? MT).to be_truthy
    end

    it 'finds the data file' do
      expect(Aruba.config.working_directory).to eq 'tmp/aruba'
      expect(Dir.exist? "#{Aruba.config.working_directory}/data").to be_truthy
      expect(File.exist? "#{Aruba.config.working_directory}/data/config.yml").to be_truthy
    end

    it 'prints a usage message' do
      command
      expect(last_command_started).to be_successfully_executed
      expect(last_command_started.stdout).to match(/Manager Tools commands/)
    end
  end

  context 'with help command' do
    let(:command) do
      run_command_and_stop("#{MT} help")
    end

    it 'prints a usage message' do
      command
      expect(last_command_started).to be_successfully_executed
      expect(last_command_started.stdout).to match(/Manager Tools commands/)
    end
  end

  context 'with undefined subcommand' do
    let(:command) do
      run_command_and_stop("#{MT} xyzzy", fail_on_error: false)
    end

    it 'prints an error' do
      command
      expect(last_command_started).not_to be_successfully_executed
      expect(last_command_started.stderr).to match(/Could not find command "xyzzy"/)
    end
  end
end
