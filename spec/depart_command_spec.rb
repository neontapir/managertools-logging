# frozen_string_literal: true

require './lib/settings'
require './lib/commands/depart_command'
require './lib/commands/new_hire_command'
require_relative 'spec_helper'

RSpec.describe DepartCommand do
  context 'moving a departing team member' do
    departed_folder = File.join(%W[#{Settings.root} #{Settings.departed_root}])
    old_team_folder = File.join(%W[#{Settings.root} teen-titans])
    starfire = 'princess-koriandr'

    before :each do
      FileUtils.rm_r departed_folder if Dir.exist? departed_folder
      FileUtils.mkdir_p old_team_folder

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
    end

    after :each do
      FileUtils.rm_r old_team_folder
    end

    it 'relocates their files' do
      expect(Dir).not_to exist(departed_folder)

      expect { subject.command 'Princess' }.to output(/Princess Koriandr/).to_stdout

      expect(Dir).to exist(File.join(%W[#{departed_folder} #{starfire}]))
      expect(Dir).not_to exist(File.join(%W[#{old_team_folder} #{starfire}]))
    end
  end
end
