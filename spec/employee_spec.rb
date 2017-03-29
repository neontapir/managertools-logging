require 'ostruct'
require './lib/employee.rb'

describe Employee do
  context 'when getting the name' do
    it 'should be capitalized if input is capitalized' do
      cap = { team: 'Avengers', first: 'Steve', last: 'Rogers' }
      captain_america = Employee.new cap
      expect(captain_america.to_s).to eq 'Steve Rogers'
    end

    it 'should be capitalized name even if input is not capitalized' do
      cap = { team: 'avengers', first: 'steve', last: 'rogers' }
      captain_america = Employee.new cap
      expect(captain_america.to_s).to eq 'Steve Rogers'
    end
  end

  context 'in Iron Man context' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
      @iron_man = Employee.find('tony')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'should parse a folder correctly' do
      dir = Dir.new('data/avengers/tony-stark')
      iron_man = Employee.parse_dir(dir)
      expect(iron_man.fetch(:team)).to eq 'avengers'
      expect(iron_man.fetch(:first)).to eq 'Tony'
      expect(iron_man.fetch(:last)).to eq 'Stark'
    end

    it 'should find Iron Man' do
      expect(@iron_man).not_to be_nil
      expect(@iron_man.team).to eq 'avengers'
      expect(@iron_man.first).to eq 'Tony'
      expect(@iron_man.last).to eq 'Stark'
    end

    it 'should give the correct log file location' do
      file = @iron_man.file
      expect(file).not_to be_nil
      expect(file.path).to eq 'data/avengers/tony-stark/log.adoc'
    end

    it 'should give Iron Man\'s name' do
      expect(@iron_man.to_s).to eq 'Tony Stark'
    end

    it 'equality should match on team, first, and last name' do
      expect(@iron_man).to eq Employee.new(team: 'avengers', first: 'Tony', last: 'Stark')
      expect(@iron_man).not_to eq Employee.new(team: 'justice-league', first: 'Tony', last: 'Stark')
      expect(@iron_man).not_to eq Employee.new(team: 'avengers', first: 'Anthony', last: 'Stark')
      expect(@iron_man).not_to eq Employee.new(team: 'avengers', first: 'Tony', last: 'Starkraving')
    end

    it 'equality should not match on invalid objects' do
      expect(@iron_man).not_to eq 'Tony Stark of the Avengers'
      expect(@iron_man).not_to eq OpenStruct.new(first: 'Tony', last: 'Stark') # no team
      expect(@iron_man).not_to eq OpenStruct.new(team: 'avengers', last: 'Stark') # no first
      expect(@iron_man).not_to eq OpenStruct.new(team: 'avengers', first: 'Tony') # no last
    end

    it 'should not find Captain America' do
      employee = Employee.find('steve')
      expect(employee).to be_nil
    end
  end

  context 'in Ant Man and Beast context' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/hank-pym')   # Ant Man
      FileUtils.mkdir_p('data/avengers/hank-mccoy') # Beast
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'should return first in alphabetical order if multiples match' do
      beast = Employee.find('hank')
      expect(beast).not_to be_nil
      expect(beast.team).to eq 'avengers'
      expect(beast.first).to eq 'Hank'
      expect(beast.last).to eq 'Mccoy'
    end

    it 'should find someone if given a unique key' do
      ant_man = Employee.find('hank-p')
      expect(ant_man).not_to be_nil
      expect(ant_man.team).to eq 'avengers'
      expect(ant_man.first).to eq 'Hank'
      expect(ant_man.last).to eq 'Pym'
    end
  end
end
