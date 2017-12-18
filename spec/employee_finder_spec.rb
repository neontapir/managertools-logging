# frozen_string_literal: true

require 'ostruct'
require 'stringio'
require './lib/employee.rb'
require './lib/settings.rb'
require_relative 'captured_io'
require_relative 'settings_helper'

describe EmployeeFinder do
  include CapturedIO
  include SettingsHelper

  subject { (Class.new { include EmployeeFinder }).new }

  context 'with a non-existing employee (Red Panda)' do
    it 'will prompt the user for a spec if the employee is not found' do
      input = StringIO.new("Terrific Twosome of Toronto\n\Kit\nBaxter\n")
      with_captured(input) do |_|
        flying_squirrel = subject.get('Kit', :superhero)
        expect(flying_squirrel.team).to eq('Terrific Twosome of Toronto')
        expect(flying_squirrel.first).to eq('Kit')
        expect(flying_squirrel.last).to eq('Baxter')
      end
    end

    it 'can create a spec with no input' do
      defaults = { first: 'Zaphod', last: 'Beeblebrox', team: Settings.candidates_root }
      input = StringIO.new("\n\n\n")
      with_captured(input) do |_|
        expect(subject.create_spec(:superhero, {})).to eq(defaults)
      end
    end

    it 'can create a spec with give input' do
      red_panda = { first: 'August', last: 'Fenwick', team: 'Terrific Twosome of Toronto' }
      input = StringIO.new("Terrific Twosome of Toronto\nAugust\nFenwick\n")
      with_captured(input) do |_|
        expect(subject.create_spec(:superhero, {})).to eq(red_panda)
      end
    end

    it 'will not prompt for an interview candidate' do
      flying_squirrel = { first: 'Kit', last: 'Baxter', team: Settings.candidates_root }
      input = StringIO.new("Kit\nBaxter\n")
      with_captured(input) do |_|
        expect(subject.create_spec(:interview, {})).to eq(flying_squirrel)
      end
    end
  end

  def is_correct?(employee, team, first, last)
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
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'extracts the data correctly' do
      dir = Dir.new('data/avengers/tony-stark')
      iron_man = subject.parse_dir(dir)
      expect(is_correct?(iron_man, 'avengers', 'Tony', 'Stark')).to be_truthy
    end
  end

  context 'when finding an employee (Iron Man)' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    subject do
      finder = (Class.new { include EmployeeFinder }).new
      finder.find('tony')
    end

    it 'does not find a different employee' do
      employee = Employee.find('steve')
      expect(employee).to be_nil
    end
  end

  context 'with two employees with same first name (Ant Man and Beast)' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/hank-pym')   # Ant Man
      FileUtils.mkdir_p('data/avengers/hank-mccoy') # Beast
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'returns the first one by alphabetical order if multiples match' do
      hanks = Employee.find('hank')
      is_correct?(hanks, 'avengers', 'Hank', 'Mccoy')
    end

    it 'finds the expected employee when given a unique key' do
      ant_man = Employee.find('hank-p')
      is_correct?(ant_man, 'avengers', 'Hank', 'Pym')

      beast = Employee.find('hank-m')
      is_correct?(beast, 'avengers', 'Hank', 'Mccoy')
    end
  end
end
