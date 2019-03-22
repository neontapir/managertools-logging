# frozen_string_literal: true

require 'ostruct'
require 'stringio'
require './lib/employee.rb'
require './lib/settings.rb'
require_relative 'settings_helper'

describe Employee do
  include SettingsHelper

  def proper?(employee, team, first, last)
    Struct.new("EmployeeSpec", :team, :first, :last)
    expect(employee <=> EmployeeSpec.new(team, first, last)).to eq 0
  end

  context 'when getting the name' do
    subject { { team: 'Avengers', first: 'Steve', last: 'Rogers' } }

    it 'is capitalized if input is capitalized' do
      captain_america = Employee.new subject
      expect(captain_america.to_s).to eq 'Steve Rogers'
    end

    it 'is capitalized name even if input is not capitalized' do
      captain_lowercase = { team: 'avengers', first: 'steve', last: 'rogers' }
      captain_america = Employee.new captain_lowercase
      expect(captain_america.to_s).to eq 'Steve Rogers'
    end

    it 'is available as a canonical name' do
      captain_america = Employee.new subject
      expect(captain_america.canonical_name).to eq 'steve-rogers'
    end
  end

  context 'with equality for a single employee (Iron Man)' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    subject { Employee.new(team: 'avengers', first: 'Tony', last: 'Stark') }

    it 'gives the correct log file location' do
      file = subject.file
      expect(file).not_to be_nil
      expect(file.path).to eq 'data/avengers/tony-stark/log.adoc'
    end

    it 'gives the employee\'s name' do
      expect(subject.to_s).to eq 'Tony Stark'
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
    before(:all) do
      FileUtils.mkdir_p('data/justice-league/diana-prince')
    end

    after(:all) do
      FileUtils.rm_r('data/justice-league')
    end

    subject { Employee.new(team: 'Justice League', first: 'Diana', last: 'Prince') }

    it 'gives the correct log file location' do
      file = subject.file
      expect(file).not_to be_nil
      expect(file.path).to eq 'data/justice-league/diana-prince/log.adoc'
    end
  end
end
