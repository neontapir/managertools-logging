# frozen_string_literal: true

require 'ostruct'
require 'stringio'
require './lib/employee.rb'
require './lib/employee_finder.rb'
require './lib/settings.rb'
require_relative 'settings_helper'

RSpec.describe EmployeeFinder do
  include SettingsHelper

  subject { (Class.new { include EmployeeFinder }).new }

  context 'with a non-existing employee (Red Panda)' do
    it 'will prompt the user for a spec if the employee is not found' do
      allow(Settings.console).to receive(:ask) do |prompt|
        case prompt
        when /Team/ then 'Terrific Twosome of Toronto'
        when /First/ then 'Kit'
        when /Last/ then 'Baxter'
        end
      end
      flying_squirrel = subject.get('Kit', :superhero)
      expect(flying_squirrel.team).to eq 'Terrific Twosome of Toronto'
      expect(flying_squirrel.first).to eq 'Kit'
      expect(flying_squirrel.last).to eq 'Baxter'
    end

    it 'can create a spec with no input' do
      defaults = { first: 'Zaphod', last: 'Beeblebrox', team: Settings.candidates_root }
      Settings.with_mock_input("\n\n\n") do
        expect(subject.create_spec(:superhero, {})).to eq defaults
      end
    end

    it 'can create a spec with given input' do
      red_panda = { first: 'August', last: 'Fenwick', team: 'Terrific Twosome of Toronto' }
      allow(Settings.console).to receive(:ask) do |prompt|
        case prompt
        when /Team/ then 'Terrific Twosome of Toronto'
        when /First/ then 'August'
        when /Last/ then 'Fenwick'
        end
      end
      expect(subject.create_spec(:superhero, {})).to eq red_panda
    end

    it 'will not prompt for team for an interview candidate' do
      flying_squirrel = { first: 'Kit', last: 'Baxter', team: Settings.candidates_root }
      allow(Settings.console).to receive(:ask) do |prompt|
        case prompt
          when /First/ then 'Kit'
          when /Last/ then 'Baxter'
        end
      end
      expect(subject.create_spec(:interview, {})).to eq flying_squirrel
    end
  end

  def proper?(employee, team, first, last)
    expect(employee).not_to be_nil
    employee_team = employee.instance_of?(Employee) ? employee.team : employee.fetch(:team)
    expect(employee_team).to eq team
    employee_first = employee.instance_of?(Employee) ? employee.first : employee.fetch(:first)
    expect(employee_first).to eq first
    employee_last = employee.instance_of?(Employee) ? employee.last : employee.fetch(:last)
    expect(employee_last).to eq last
  end

  context 'when parsing an employee folder (Iron Man)' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    it 'extracts the data correctly' do
      dir = Dir.new('data/avengers/tony-stark')
      iron_man = subject.parse_dir(dir)
      expect(proper?(iron_man, 'avengers', 'Tony', 'Stark')).to be_truthy
    end
  end

  context 'when parsing an employee folder with a hyphen (Rescue)' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers/pepper-potts-stark'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    it 'extracts the data correctly' do
      dir = Dir.new('data/avengers/pepper-potts-stark')
      avenger_rescue = subject.parse_dir(dir)
      expect(proper?(avenger_rescue, 'avengers', 'Pepper', 'Potts-Stark')).to be_truthy
    end
  end

  context 'when finding an employee (Iron Man)' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    it 'does find the expected employee' do
      expect(subject.find('tony')).not_to be_nil
    end

    it 'does find the expected employee with capitalized case' do
      expect(subject.find('Tony')).not_to be_nil
    end

    it 'does not find a different employee' do
      expect(subject.find('steve')).to be_nil
    end
  end

  context 'with two employees with same first name (Ant Man and Beast)' do
    before(:all) do
      FileUtils.mkdir_p 'data/avengers/hank-pym'   # Ant Man
      FileUtils.mkdir_p 'data/avengers/hank-mccoy' # Beast
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    it 'returns the first one by alphabetical order if multiples match' do
      hanks = subject.find('hank')
      proper?(hanks, 'avengers', 'Hank', 'Mccoy')
    end

    it 'finds the expected employee when given a unique key' do
      ant_man = subject.find('hank-p')
      proper?(ant_man, 'avengers', 'Hank', 'Pym')

      ant_man_by_last_name = subject.find('pym')
      proper?(ant_man_by_last_name, 'avengers', 'Hank', 'Pym')

      beast = subject.find('hank-m')
      proper?(beast, 'avengers', 'Hank', 'Mccoy')
    end
  end
end
