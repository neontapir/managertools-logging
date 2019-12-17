# frozen_string_literal: true

require './lib/team'
require_relative 'settings_helper'

RSpec.describe TeamFinder do
  include SettingsHelper

  subject { (Class.new { include TeamFinder }).new }

  context 'when parsing a team folder (Avengers)' do
    avengers_folder = File.join(%W[#{Settings.root} avengers])

    before(:all) do
      FileUtils.mkdir_p avengers_folder
    end

    after(:all) do
      FileUtils.rm_r avengers_folder
    end

    let(:dir) { Dir.new(avengers_folder) }

    it 'extracts the data correctly' do
      team = subject.parse_dir(dir)
      expect(team).to eq team: 'avengers'
    end
  end

  context 'when finding a team (Avengers)' do
    avengers_folder = File.join(%W[#{Settings.root} avengers])
    justice_league_folder_spec = File.join(%W[#{Settings.root} justice]) + '*' 

    before(:all) do
      FileUtils.mkdir_p avengers_folder
      FileUtils.rm_r justice_league_folder_spec if Dir.exist? justice_league_folder_spec
    end

    after(:all) do
      FileUtils.rm_r avengers_folder
    end

    let(:expected) { Team.new(team: 'avengers') }

    it 'does find an existing team by full name' do
      team = subject.find('avengers')
      expect(team).to eq expected
    end

    it 'does find an existing team by partial name' do
      team = subject.find('avenge')
      expect(team).to eq expected
    end

    it 'does not find a team that has no folder' do
      team = Team.find('justice')
      expect(team).to be_nil
    end
  end

  context 'when finding a team with spaces in the name (League of Extraordinary Gentlemen)' do
    league_id = 'league-of-extraordinary-gentlemen'
    league_folder = File.join(%W[#{Settings.root} #{league_id}])

    before(:all) do
      FileUtils.mkdir_p league_folder
    end

    after(:all) do
      FileUtils.rm_r league_folder
    end

    let(:expected) { Team.new(team: league_id) }

    it 'does find an existing team by full name' do
      team = subject.find('League of Extraordinary Gentlemen')
      expect(team).to eq expected
    end

    it 'does find an existing team by partial name' do
      team = subject.find('leagu')
      expect(team).to eq expected
    end
  end
end
