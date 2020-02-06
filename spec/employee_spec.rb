# frozen_string_literal: true

require 'ostruct'
require 'stringio'
require './lib/employee'
require './lib/settings'
require_relative 'settings_helper'

RSpec.describe Employee do
  include SettingsHelper

  context 'when getting the name (Quicksilver)' do
    let(:quicksilver_data) { { team: 'Avengers', first: 'Pietro', last: 'Maximoff' } }

    it 'is capitalized when input is capitalized' do
      quicksilver = Employee.new(**quicksilver_data)
      expect(quicksilver.to_s).to eq 'Pietro Maximoff'
    end

    it 'is capitalized even when input is not capitalized' do
      quicksilver_lowercase = quicksilver_data.dup.transform_values(&:downcase)
      quicksilver = Employee.new(**quicksilver_lowercase)
      expect(quicksilver.to_s).to eq 'Pietro Maximoff'
    end

    it 'is available as a canonical name' do
      quicksilver = Employee.new(**quicksilver_data)
      expect(quicksilver.canonical_name).to eq 'pietro-maximoff'
    end
  end

  context 'when getting names with unusual casing (Porthos, et al)' do
    people_folder = File.join %W[#{Settings.root} people]

    before :all do
      %w[baron-du-vallon-de-bracieux-de-pierrefonds old-mcdonald jj-ginger-oconnell].each do |p|
        FileUtils.mkdir_p File.join(people_folder, p)
      end
    end

    after :all do
      FileUtils.rm_r people_folder
    end

    it 'handles French names', :aggregate_failures do
      porthos = Employee.new(team: 'people', first: 'Baron'.downcase, last: 'du Vallon de Bracieux de Pierrefonds'.downcase)
      expect(porthos.canonical_name).to eq 'baron-du-vallon-de-bracieux-de-pierrefonds'
      expect(porthos.to_s).to eq 'Baron du Vallon de Bracieux de Pierrefonds'
    end

    it 'handles Irish Mac names', :aggregate_failures do
      old_mcdonald = Employee.new(team: 'people', first: 'Old'.upcase, last: 'McDonald'.upcase)
      expect(old_mcdonald.canonical_name).to eq 'old-mcdonald'
      expect(old_mcdonald.to_s).to eq 'Old McDonald'
    end

    it 'handles Irish accented names', :aggregate_failures do
      o_madagain = Employee.new(team: 'people', first: 'breandán'.upcase, last: "ó madagáin".upcase)
      expect(o_madagain.canonical_name).to eq 'breandán-ó-madagáin'
      expect(o_madagain.to_s).to eq 'Breandán ó Madagáin'
    end

    it 'handles Irish O names', :aggregate_failures do
      oconnell = Employee.new(team: 'people', first: 'J.J. "Ginger"'.upcase, last: "O'Connell".upcase)
      expect(oconnell.canonical_name).to eq 'jj-ginger-oconnell'
      expect(oconnell.to_s).to eq "J.J. \"Ginger\" O'Connell"
    end

    it 'handles hyphenated first names', :aggregate_failures do
      cheroutre = Employee.new(team: 'people', first: 'marie-thérèse'.upcase, last: 'cheroutre'.upcase)
      expect(cheroutre.canonical_name).to eq 'marie-thérèse-cheroutre'
      expect(cheroutre.to_s).to eq 'Marie-Thérèse Cheroutre'
    end

    it 'handles suffixed names', :aggregate_failures do
      david = Employee.new(team: 'people', first: 'David'.upcase, last: 'Curry-Johnson III'.upcase)
      expect(david.canonical_name).to eq 'david-curry-johnson-iii'
      expect(david.to_s).to eq 'David Curry-Johnson III'
    end
  end

  context 'with equality for a single employee (Two-Gun Kid)' do
    subject(:two_gun_kid) { Employee.new(team: 'avengers', first: 'Matt', last: 'Hawk') }
    two_gun_kid_folder = File.join %W[#{Settings.root} avengers matt-hawk]

    before :all do
      FileUtils.mkdir_p two_gun_kid_folder
    end

    after :all do
      FileUtils.rm_r File.dirname(two_gun_kid_folder)
    end

    it 'gives the correct log file location', :aggregate_failures do
      file = two_gun_kid.file
      expect(file).not_to be_nil
      expect(file.path).to eq File.join(two_gun_kid_folder, Settings.log_filename)
    end

    it 'gives the employee\'s name' do
      expect(two_gun_kid.to_s).to eq 'Matt Hawk'
    end

    it 'equality should match on team, first, and last name', :aggregate_failures do
      is_expected.to eq Employee.new(team: 'avengers', first: 'Matt', last: 'Hawk')
      is_expected.not_to eq Employee.new(team: 'justice-league', first: 'Matt', last: 'Hawk')
      is_expected.not_to eq Employee.new(team: 'avengers', first: 'Anthony', last: 'Hawk')
      is_expected.not_to eq Employee.new(team: 'avengers', first: 'Matt', last: 'Hawking')
    end

    it 'equality should not match on invalid objects', :aggregate_failures do
      is_expected.not_to eq 'Matt Hawk of the Avengers'
      is_expected.not_to eq OpenStruct.new(first: 'Matt', last: 'Hawk') # no team
      is_expected.not_to eq OpenStruct.new(team: 'avengers', last: 'Hawk') # no first
      is_expected.not_to eq OpenStruct.new(team: 'avengers', first: 'Matt') # no last
    end
  end

  context 'with equality for a single employee with a hyphenated team name (Wonder Woman)' do
    subject(:wonder_woman) { Employee.new(team: 'Justice League', first: 'Diana', last: 'Prince') }
    wonder_woman_folder = File.join %W[#{Settings.root} justice-league diana-prince]

    before :all do
      FileUtils.mkdir_p wonder_woman_folder
    end

    after :all do
      FileUtils.rm_r File.dirname(wonder_woman_folder)
    end

    it 'gives the correct log file location', :aggregate_failures do
      file = wonder_woman.file
      expect(file).not_to be_nil
      expect(file.path).to eq File.join(wonder_woman_folder, Settings.log_filename)
    end
  end

  context 'abnormal initialization' do
    it 'raises on mising keys', :aggregate_failures do
      expect { Employee.new() }.to raise_error KeyError
      expect { Employee.new(first: 'John', last: 'Smith') }.to raise_error KeyError
      expect { Employee.new(team: 'normal', last: 'Smith') }.to raise_error KeyError
      expect { Employee.new(team: 'normal', first: 'John') }.to raise_error KeyError
    end

    it 'raises on invalid team name', :aggregate_failures do
      expect { Employee.new(team: '', first: 'John', last: 'Smith') }.to raise_error ArgumentError
      expect { Employee.new(team: nil, first: 'John', last: 'Smith') }.to raise_error ArgumentError
    end

    it 'raises on invalid first name', :aggregate_failures do
      expect { Employee.new(team: 'normal', first: '', last: 'Smith') }.to raise_error ArgumentError
      expect { Employee.new(team: 'normal', first: nil, last: 'Smith') }.to raise_error ArgumentError
    end

    it 'raises on invalid last name', :aggregate_failures do
      expect { Employee.new(team: 'normal', first: 'John', last: '') }.to raise_error ArgumentError
      expect { Employee.new(team: 'normal', first: 'John', last: nil) }.to raise_error ArgumentError
    end
  end
end
