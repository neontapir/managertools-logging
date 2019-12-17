# frozen_string_literal: true

require 'ostruct'
require 'stringio'
require './lib/employee'
require './lib/settings'
require_relative 'settings_helper'

RSpec.describe Employee do
  include SettingsHelper

  context 'when getting the name' do
    let(:cap_spec) { { team: 'Avengers', first: 'Steve', last: 'Rogers' } }

    it 'is capitalized if input is capitalized' do
      captain_america = Employee.new cap_spec
      expect(captain_america.to_s).to eq 'Steve Rogers'
    end

    it 'is capitalized name even if input is not capitalized' do
      captain_lowercase = { team: 'avengers', first: 'steve', last: 'rogers' }
      captain_america = Employee.new captain_lowercase
      expect(captain_america.to_s).to eq 'Steve Rogers'
    end

    it 'is available as a canonical name' do
      captain_america = Employee.new cap_spec
      expect(captain_america.canonical_name).to eq 'steve-rogers'
    end
  end

  context 'when getting names with unusual casing' do
    people_folder = File.join(%W[#{Settings.root} people])

    before :all do
      %w[baron-du-vallon-de-bracieux-de-pierrefonds old-mcdonald jj-ginger-oconnell].each do |p|
        FileUtils.mkdir_p File.join(people_folder, p)
      end
    end

    after :all do
      FileUtils.rm_r people_folder
    end

    it 'is handles French names' do
      porthos = Employee.new({ team: 'people', first: 'Baron'.downcase, last: 'du Vallon de Bracieux de Pierrefonds'.downcase })
      expect(porthos.to_s).to eq 'Baron du Vallon de Bracieux de Pierrefonds'
    end

    it 'it handles Irish Mac names' do
      old_mcdonald = Employee.new({ team: 'people', first: 'Old'.upcase, last: 'McDonald'.upcase })
      expect(old_mcdonald.to_s).to eq 'Old McDonald'
    end

    it 'it handles Irish O names' do
      oconnell = Employee.new({ team: 'people', first: 'J.J. "Ginger"'.upcase, last: "O'Connell".upcase })
      expect(oconnell.to_s).to eq "J.J. \"Ginger\" O'Connell"
    end
  end

  context 'with equality for a single employee (Iron Man)' do    
    subject(:iron_man) { Employee.new(team: 'avengers', first: 'Tony', last: 'Stark') }
    iron_man_folder = File.join(%W[#{Settings.root} avengers tony-stark])

    before :all do
      FileUtils.mkdir_p iron_man_folder
    end

    after :all do
      FileUtils.rm_r File.dirname(iron_man_folder)
    end
    
    it 'gives the correct log file location' do
      file = iron_man.file
      expect(file).not_to be_nil
      expect(file.path).to eq File.join(iron_man_folder, 'log.adoc')
    end

    it 'gives the employee\'s name' do
      expect(iron_man.to_s).to eq 'Tony Stark'
    end

    it 'equality should match on team, first, and last name' do
      is_expected.to eq Employee.new(team: 'avengers', first: 'Tony', last: 'Stark')
      is_expected.not_to eq Employee.new(team: 'justice-league', first: 'Tony', last: 'Stark')
      is_expected.not_to eq Employee.new(team: 'avengers', first: 'Anthony', last: 'Stark')
      is_expected.not_to eq Employee.new(team: 'avengers', first: 'Tony', last: 'Starkraving')
    end

    it 'equality should not match on invalid objects' do
      is_expected.not_to eq 'Tony Stark of the Avengers'
      is_expected.not_to eq OpenStruct.new(first: 'Tony', last: 'Stark') # no team
      is_expected.not_to eq OpenStruct.new(team: 'avengers', last: 'Stark') # no first
      is_expected.not_to eq OpenStruct.new(team: 'avengers', first: 'Tony') # no last
    end
  end

  context 'with equality for a single employee with a hyphenated team name (Wonder Woman)' do
    subject(:wonder_woman) { Employee.new(team: 'Justice League', first: 'Diana', last: 'Prince') }
    wonder_woman_folder = File.join(%W[#{Settings.root} justice-league diana-prince])

    before :all do
      FileUtils.mkdir_p wonder_woman_folder
    end

    after :all do
      FileUtils.rm_r File.dirname(wonder_woman_folder)
    end

    it 'gives the correct log file location' do
      file = wonder_woman.file
      expect(file).not_to be_nil
      expect(file.path).to eq File.join(wonder_woman_folder, 'log.adoc')
    end
  end
end
