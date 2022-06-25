# frozen_string_literal: true

require './lib/project'
require './lib/project_finder'
require './lib/project_folder'
require_relative 'settings_helper'

RSpec.describe ProjectFinder do
  subject(:project_finder) { (Class.new { include ProjectFinder }).new }

  after do
    FileUtils.rm_r ProjectFolder.root
  end

  def bloodties_folder
    File.join(ProjectFolder.root, 'bloodties')
  end

  def galactic_storm_folder
    File.join(ProjectFolder.root, 'galactic-storm')
  end

  include SettingsHelper

  context 'when parsing a project folder (Bloodtide)' do
    before do
      FileUtils.mkdir_p bloodties_folder
    end

    after do
      FileUtils.rm_r bloodties_folder
    end

    let(:dir) { Dir.new(bloodties_folder) }

    it 'extracts the data correctly' do
      project = project_finder.parse_dir(dir)
      expect(project).to eq project: 'bloodties'
    end
  end

  context 'when finding a project (Bloodtide)' do
    before do
      FileUtils.mkdir_p bloodties_folder
    end

    after do
      FileUtils.rm_r bloodties_folder
    end

    let(:expected) { Project.new(project: 'bloodties') }

    it 'does find an existing project by full name' do
      project = project_finder.find('bloodties')
      expect(project).to eq expected
    end

    it 'does find an existing project by partial name' do
      project = project_finder.find('blood')
      expect(project).to eq expected
    end

    it 'does not find a project that has no folder' do
      project = project_finder.find('galactic-storm')
      expect(project).to be_nil
    end
  end

  context 'when finding a project with spaces in the name (Galactic Storm)' do
    before do
      FileUtils.mkdir_p galactic_storm_folder
    end

    after do
      FileUtils.rm_r galactic_storm_folder
    end

    let(:expected) { Project.new(project: 'galactic-storm') }

    it 'does find an existing project by full name' do
      project = project_finder.find('Galactic Storm')
      expect(project).to eq expected
    end

    it 'does find an existing project by partial name' do
      project = project_finder.find('galac')
      expect(project).to eq expected
    end
  end
end
