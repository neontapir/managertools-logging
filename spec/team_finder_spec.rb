# frozen_string_literal: true

require './lib/team'
require_relative 'settings_helper'

RSpec.describe TeamFinder do
  include SettingsHelper

  subject(:finder) { (Class.new { include TeamFinder }).new }

  shared_examples 'finding' do |team_name, expected|
    expected = Team.new(team: team_name)

    it 'by full name' do
      team = finder.find(team_name)
      expect(team).to eq expected
    end

    it 'by partial name' do
      team = finder.find(team_name[0, 3])
      expect(team).to eq expected
    end
  end

  context 'with a typical team (Watchmen)' do
    watchmen_folder = File.join %W[#{Settings.root} watchmen]

    before :context do
      FileUtils.mkdir_p watchmen_folder
    end

    after :context do
      FileUtils.rm_r watchmen_folder
    end

    it_has_behavior 'finding', 'watchmen'

    it 'parses the folder data correctly' do
      dir = Dir.new(watchmen_folder)
      team = finder.parse_dir(dir)
      expect(team).to eq team: 'watchmen'
    end
  end

  context 'with a team with spaces in the name (League of Extraordinary Gentlemen)' do
    league_id = 'league-of-extraordinary-gentlemen'
    league_folder = File.join %W[#{Settings.root} #{league_id}]

    before :context do
      FileUtils.mkdir_p league_folder
    end

    after :context do
      FileUtils.rm_r league_folder
    end

    it_has_behavior 'finding', league_id
  end

  context 'with two team with similar names (Justice League and Justice Society)' do
    justice_league_id = 'justice-league'
    justice_league_folder = File.join %W[#{Settings.root} #{justice_league_id}]

    justice_society_id = 'justice-society'
    justice_society_folder = File.join %W[#{Settings.root} #{justice_society_id}]

    before :context do
      [justice_league_folder, justice_society_folder].each do |group_folder|
        FileUtils.mkdir_p group_folder
      end
    end

    after :context do
      [justice_league_folder, justice_society_folder].each do |group_folder|
        FileUtils.rm_r group_folder
      end
    end

    it 'does not find a team that has no folder' do
      team = Team.find('avengers')
      expect(team).to be_nil
    end

    it 'finds a team by its full name' do
      [justice_league_id, justice_society_id].each do |name|
        team = finder.find(name)
        expect(team.path).to eq name
      end
    end

    it 'finds a team by unique identifier' do
      [justice_league_id, justice_society_id].each do |name|
        team = finder.find(name[0, 9]) # justice_l or justice_s
        expect(team.path).to eq name
      end
    end

    it 'finds first team in alphabetical order when multiple match' do
      team = finder.find('justice')
      expect(team.path).to eq justice_league_id
    end
  end
end
