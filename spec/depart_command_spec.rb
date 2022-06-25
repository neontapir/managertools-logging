# frozen_string_literal: true

require './lib/settings'
require './lib/commands/depart_command'
require './lib/commands/new_hire_command'
require_relative 'spec_helper'

RSpec.describe DepartCommand do
  subject(:depart) { described_class.new }

  context 'when moving a departing team member (Demolition Man)' do
    departed_folder = File.join(Settings.root, Settings.departed_root)
    old_team_folder = File.join(Settings.root, 'revengers')
    demolition_man = 'dennis-dunphy'

    before do
      expect(Dir).not_to exist departed_folder
      FileUtils.mkdir_p old_team_folder

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Revengers Dennis Dunphy] }.to output(/#{demolition_man}/).to_stdout
    end

    after do
      [old_team_folder, departed_folder].each { |folder| FileUtils.rm_r folder }
    end

    it 'relocates their files', :aggregate_failures do
      expect(Dir).not_to exist(departed_folder)

      expect { depart.command 'dunphy' }.to output(/Dennis Dunphy/).to_stdout

      expect(Dir).to exist(File.join(%W[#{departed_folder} #{demolition_man}]))
      expect(Dir).not_to exist(File.join(%W[#{old_team_folder} #{demolition_man}]))
    end

    it 'does not update the team line in the overview file' do
      expect { depart.command 'dunphy' }.to output(/Dennis Dunphy/).to_stdout
      demolition_man_employee = Employee.find('Dennis')
      new_folder = demolition_man_employee.file.folder
      overview_location = File.join new_folder, Settings.overview_filename
      overview_contents = File.read(overview_location)
      expect(overview_contents).to match(/^Team: Revengers\s*$/m)
      expect(overview_contents).not_to match(/^Team:.*departed/im)
    end
  end

  context 'with a team as the move subject yields the first person (Justic League)' do
    departed_folder = File.join(Settings.root, Settings.departed_root)
    old_team_folder = File.join(Settings.root, 'justice-league')
    batman = 'bruce-wayne'
    wonder_woman = 'diana-prince'

    before do
      expect(Dir).not_to exist departed_folder
      FileUtils.mkdir_p old_team_folder

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[justice-league Bruce Wayne] }.to output(/#{batman}/).to_stdout
      expect { NewHireCommand.new.command %w[justice-league Diana Prince] }.to output(/#{wonder_woman}/).to_stdout
    end

    after do
      [old_team_folder, departed_folder].each { |folder| FileUtils.rm_r folder }
    end

    it 'relocates the first person\'s files', :aggregate_failures do
      expect(Dir).not_to exist(departed_folder)

      expect { depart.command 'justice-league' }.to output(/Bruce Wayne/).to_stdout

      expect(Dir).to exist(File.join(%W[#{departed_folder} #{batman}]))
      expect(Dir).not_to exist(File.join(%W[#{departed_folder} #{wonder_woman}]))
      expect(Dir).not_to exist(File.join(%W[#{old_team_folder} #{batman}]))
      expect(Dir).to exist(File.join(%W[#{old_team_folder} #{wonder_woman}]))
    end
  end
end
