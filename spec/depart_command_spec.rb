# frozen_string_literal: true

require './lib/settings'
require './lib/commands/depart_command'
require './lib/commands/new_hire_command'
require_relative 'spec_helper'

RSpec.describe DepartCommand do
  context 'moving a departing team member (Demolition Man)' do
    departed_folder = File.join %W[#{Settings.root} #{Settings.departed_root}]
    old_team_folder = File.join %W[#{Settings.root} revengers]
    demolition_man = 'dennis-dunphy'

    before do
      FileUtils.rm_r departed_folder if Dir.exist? departed_folder
      FileUtils.mkdir_p old_team_folder

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Revengers Dennis Dunphy] }.to output(/#{demolition_man}/).to_stdout
    end

    after do
      [old_team_folder, departed_folder].each { |folder| FileUtils.rm_r folder }
    end

    it 'relocates their files', :aggregate_failures do
      expect(Dir).not_to exist(departed_folder)

      expect { subject.command 'dunphy' }.to output(/Dennis Dunphy/).to_stdout

      expect(Dir).to exist(File.join(%W[#{departed_folder} #{demolition_man}]))
      expect(Dir).not_to exist(File.join(%W[#{old_team_folder} #{demolition_man}]))
    end
  end
end
