# frozen_string_literal: true

unless defined? MT
  MT = File.expand_path('../mt', __FILE__)
  load MT
end

require_relative 'settings_helper'
require_relative 'spec_helper'

RSpec.describe 'mt script', type: :aruba do
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

    it 'finds the data file created by the test suite' do
      # admittedly, this is more a test of Aruba than of MT
      expect(Aruba.config.working_directory).to eq 'tmp/aruba'
      expect(Dir.exist? "#{Aruba.config.working_directory}/data").to be_truthy
      expect(File.exist? "#{Aruba.config.working_directory}/data/config.yml").to be_truthy
    end

    context 'after running the command' do
      subject do
        command
        last_command_started.stdout
      end

      it 'prints a usage message' do
        expect(subject).to match(/Manager Tools commands/)
      end

      it 'the usage message contains all known commands' do
        %w[depart feedback gen goal interview latest move new o3 obs open perf report report_team team_meeting].each do |subcommand|
          expect(subject).to match(/^\s*?\w+ #{subcommand}/)
        end
      end
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
