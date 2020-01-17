# frozen_string_literal: true

require './lib/project'
require './lib/project_finder'
require_relative 'settings_helper'

RSpec.describe ProjectFinder do
  after :context do
    FileUtils.rm_r File.join(%W[#{Settings.root} projects])
  end

  def bloodties_folder
    File.join(%W[#{Settings.root} projects bloodties])
  end

  def galactic_storm_folder
    File.join(%W[#{Settings.root} projects galactic-storm])
  end

  include SettingsHelper

  subject { (Class.new { include ProjectFinder }).new }

  context 'when parsing a project folder (Bloodtide)' do
    before :context do
      FileUtils.mkdir_p bloodties_folder
    end

    after :context do
      FileUtils.rm_r bloodties_folder
    end

    let(:dir) { Dir.new(bloodties_folder) }

    it 'extracts the data correctly' do
      project = subject.parse_dir(dir)
      expect(project).to eq project: 'bloodties'
    end
  end

  context 'when finding a project (Bloodtide)' do
    before :context do
      FileUtils.mkdir_p bloodties_folder
      FileUtils.rm_r "#{galactic_storm_folder}*" if Dir.exist? "#{galactic_storm_folder}*"
    end

    after :context do
      FileUtils.rm_r bloodties_folder
    end

    let(:expected) { Project.new(project: 'bloodties') }

    it 'does find an existing project by full name' do
      project = subject.find('bloodties')
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
    before :context do
      FileUtils.mkdir_p galactic_storm_folder
    end

    after :context do
      FileUtils.rm_r galactic_storm_folder
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
