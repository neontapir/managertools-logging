# frozen_string_literal: true

require 'ostruct'
require 'stringio'
require './lib/employee'
require './lib/employee_finder'
require './lib/settings'
require_relative 'settings_helper'

RSpec.describe EmployeeFinder do
  include EmployeeFinder
  include SettingsHelper

  context 'finding employees' do
    subject(:finder) { (Class.new { include EmployeeFinder }).new }

    after :context do
      FileUtils.rm_r File.join(Settings.root, 'avengers')
    end

    # this context creates no files
    context 'with a non-existing employee (Red Panda)' do
      it 'will prompt the user for a spec', :aggregated_failures do
        allow(Settings.console).to receive(:ask) do |prompt|
          case prompt
          when /Team/ then 'Terrific Twosome of Toronto'
          when /First/ then 'Kit'
          when /Last/ then 'Baxter'
          end
        end
        flying_squirrel = finder.get('Kit', :superhero)
        expect(flying_squirrel).to have_attributes(team: 'Terrific Twosome of Toronto', first: 'Kit', last: 'Baxter')
      end

      it 'can create a default employee with no input' do
        defaults = Employee.new(first: 'Zaphod', last: 'Beeblebrox', team: Settings.candidates_root)
        Settings.with_mock_input("\n" * 3) do
          expect(finder.create_employee(:superhero, {})).to eq defaults
        end
      end

      it 'can create a employee with given input' do
        red_panda = Employee.new(first: 'August', last: 'Fenwick', team: 'Terrific Twosome of Toronto')
        allow(Settings.console).to receive(:ask) do |prompt|
          case prompt
          when /Team/ then 'Terrific Twosome of Toronto'
          when /First/ then 'August'
          when /Last/ then 'Fenwick'
          end
        end
        expect(finder.create_employee(:superhero, {})).to eq red_panda
      end

      it 'will not prompt for team for an interview candidate' do
        flying_squirrel = Employee.new(first: 'Kit', last: 'Baxter', team: Settings.candidates_root)
        allow(Settings.console).to receive(:ask) do |prompt|
          case prompt
          when /First/ then 'Kit'
          when /Last/ then 'Baxter'
          end
        end
        expect(finder.create_employee(:interview, {})).to eq flying_squirrel
      end
    end

    context 'when parsing an employee folder (Hulk)' do
      hulk_folder = File.join %W[#{Settings.root} avengers bruce-banner]

      before :context do
        FileUtils.mkdir_p hulk_folder
      end

      it 'extracts the data correctly' do
        dir = Dir.new(hulk_folder)
        hulk = finder.parse_dir(dir)
        expect(hulk).to have_attributes(team: 'avengers', first: 'Bruce', last: 'Banner')
      end
    end

    context 'when parsing an employee folder with a suffix (Winchester)' do
      winchester_folder = File.join %W[#{Settings.root} mash charles-emerson-winchester-iii]

      before :context do
        FileUtils.mkdir_p winchester_folder
      end

      after :context do
        FileUtils.rm_r File.dirname(winchester_folder)
      end

      it 'extracts the data correctly' do
        dir = Dir.new(winchester_folder)
        winchester = finder.parse_dir(dir)
        expect(winchester).to have_attributes(team: 'mash', first: 'Charles', last: 'Emerson-Winchester-III')
      end
    end

    context 'when parsing an employee folder with a hyphen (Rescue)' do
      rescue_folder = File.join %W[#{Settings.root} avengers pepper-potts-stark]

      before :context do
        FileUtils.mkdir_p rescue_folder
      end

      it 'extracts the data correctly' do
        dir = Dir.new(rescue_folder)
        avenger_rescue = finder.parse_dir(dir)
        expect(avenger_rescue).to have_attributes(team: 'avengers', first: 'Pepper', last: 'Potts-Stark')
      end
    end

    context 'when finding an employee (Moondragon)' do
      moondragon_folder = File.join %W[#{Settings.root} avengers heather-douglas]

      before :context do
        FileUtils.mkdir_p moondragon_folder
      end

      it 'does find the expected employee' do
        expect(finder.find('heather')).not_to be_nil
      end

      it 'does find the expected employee with capitalized case' do
        expect(finder.find('Heather')).not_to be_nil
      end

      it 'does not find a different employee' do
        expect(finder.find('steve')).to be_nil
      end
    end

    context 'with two employees with same first name (Ant Man and Beast)' do
      ant_man_folder = File.join(%W[#{Settings.root} avengers hank-pym])
      beast_folder = File.join(%W[#{Settings.root} avengers hank-mccoy])

      before do
        [ant_man_folder, beast_folder].each { |hero_folder| FileUtils.mkdir_p hero_folder }
      end

      it 'returns the first one by alphabetical order when multiples match' do
        hanks = finder.find('hank')
        expect(hanks).to have_attributes(team: 'avengers', first: 'Hank', last: 'McCoy')
      end

      it 'finds the expected employee when given a unique key', :aggregated_failures do
        ant_man = finder.find('hank-p')
        expect(ant_man).to have_attributes(team: 'avengers', first: 'Hank', last: 'Pym')

        ant_man_by_last_name = finder.find('pym')
        expect(ant_man_by_last_name).to have_attributes(team: 'avengers', first: 'Hank', last: 'Pym')

        beast = finder.find('hank-m')
        expect(beast).to have_attributes(team: 'avengers', first: 'Hank', last: 'McCoy')
      end
    end
  end
end
