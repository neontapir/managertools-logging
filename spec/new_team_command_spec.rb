# frozen_string_literal: true

require 'ostruct'
require './lib/employee'
require './lib/commands/new_team_command'
require './lib/settings'

RSpec.describe NewTeamCommand do
  subject(:new_team) { described_class.new }

  context 'when creating a new team (Guardians of the Galaxy)' do
    guardians_folder = File.join %W[#{Settings.root} guardians-of-the-galaxy]

    before do
      expect(Dir).not_to exist guardians_folder
      FileUtils.mkdir_p guardians_folder
    end

    after do
      FileUtils.rm_r guardians_folder
    end

    it 'creates a new team folder' do
      expect { new_team.command('Guardians of the Galaxy') }.to output(/Guardians of the Galaxy/).to_stdout
      expect(Dir).to exist guardians_folder
    end
  end
end
