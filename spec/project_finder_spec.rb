# frozen_string_literal: true

require './lib/project'
require './lib/project_finder'
require_relative 'settings_helper'

RSpec.describe ProjectFinder do
  include SettingsHelper

  subject { (Class.new { include ProjectFinder }).new }

  context 'when parsing a project folder (Bloodtide)' do
    before(:all) do
      FileUtils.mkdir_p 'data/projects/bloodtide'
    end

    after(:all) do
      FileUtils.rm_r 'data/projects/bloodtide'
    end

    let(:dir) { Dir.new('data/projects/bloodtide') }

    it 'extracts the data correctly' do
      project = subject.parse_dir(dir)
      expect(project).to eq project: 'bloodtide'
    end
  end

  context 'when finding a project (Bloodtide)' do
    before(:all) do
      FileUtils.mkdir_p 'data/projects/bloodtide'
      FileUtils.rm_r 'data/projects/galactic-storm*' if Dir.exist? 'data/projects/galactic-storm*'
    end

    after(:all) do
      FileUtils.rm_r 'data/projects/bloodtide'
    end

    let(:expected) { Project.new(project: 'bloodtide') }

    it 'does find an existing project by full name' do
      project = subject.find('bloodtide')
      expect(project).to eq expected
    end

    it 'does find an existing project by partial name' do
      project = subject.find('blood')
      expect(project).to eq expected
    end

    it 'does not find a project that has no folder' do
      project = Project.find('galactic-storm')
      expect(project).to be_nil
    end
  end

  context 'when finding a project with spaces in the name (Galactic Storm)' do
    before(:all) do
      FileUtils.mkdir_p 'data/projects/galactic-storm'
    end

    after(:all) do
      FileUtils.rm_r 'data/projects/galactic-storm'
    end

    let(:expected) { Project.new(project: 'galactic-storm') }

    it 'does find an existing project by full name' do
      project = subject.find('Galactic Storm')
      expect(project).to eq expected
    end

    it 'does find an existing project by partial name' do
      project = subject.find('galac')
      expect(project).to eq expected
    end
  end
end
