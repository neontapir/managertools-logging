# frozen_string_literal: true

unless defined? MT
  MT = File.expand_path('mt', __dir__)
  load MT
end

require_relative 'settings_helper'
require_relative 'spec_helper'

RSpec.describe 'mt script', type: :aruba do
  before do
    create_test_settings_file(Aruba.config.working_directory)
  end

  context 'without arguments' do
    let(:command) do
      run_command_and_stop(MT.to_s)
    end

    it 'finds the script' do
      expect(File).to exist MT
    end

    it 'finds the data file created by the test suite' do
      # admittedly, this is more a test of Aruba than of MT
      expect(Aruba.config.working_directory).to eq 'tmp/aruba'
      aruba_root = File.join %W[#{Aruba.config.working_directory} #{Settings.root}]
      expect(Dir).to exist aruba_root
      expect(File).to exist File.join(aruba_root, 'config.yml')
    end

    context 'when the command has run' do
      subject(:the_command) do
        command
        last_command_started.stdout
      end

      it 'prints a usage message' do
        expect(the_command).to match(/Manager Tools commands/)
      end

      it 'the usage message contains all known commands' do
        %w[depart feedback gen goal interview latest move new o3 obs open perf report report_team team_meeting].each do |subcommand|
          expect(the_command).to match(/^\s*?\w+ #{subcommand}/)
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
