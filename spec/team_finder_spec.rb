# frozen_string_literal: true

require './lib/team.rb'
require_relative 'settings_helper'

RSpec.describe TeamFinder do
  include SettingsHelper

  subject { (Class.new { include TeamFinder }).new }

  context 'when parsing a team folder (Avengers)' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    let(:dir) { Dir.new('data/avengers') }

    it 'extracts the data correctly' do
      team = subject.parse_dir(dir)
      expect(team).to eq team: 'avengers'
    end
  end

  context 'when finding a team (Avengers)' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers'
      FileUtils.rm_r 'data/justice*' if Dir.exist? 'data/justice*'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
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
    before(:all) do
      FileUtils.mkdir_p 'data/league-of-extraordinary-gentlemen'
    end

    after(:all) do
      FileUtils.rm_r 'data/league-of-extraordinary-gentlemen'
    end

    let(:expected) { Team.new(team: 'league-of-extraordinary-gentlemen') }

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
