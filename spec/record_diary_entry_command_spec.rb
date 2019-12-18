# frozen_string_literal: true

Dir.glob('./lib/entries/*_entry', &method(:require))
require './lib/employee'
require './lib/employee_folder'
require './lib/log_file'
require './lib/commands/record_diary_entry_command'
require './lib/settings'
require_relative 'file_contents_validation_helper'

RSpec.describe RecordDiaryEntryCommand do
  include FileContentsValidationHelper

  context 'with a single person' do
    iron_man_folder = File.join %W[#{Settings.root} avengers tony-stark]

    before do
      FileUtils.mkdir_p iron_man_folder
    end

    after do
      FileUtils.rm_r File.dirname(iron_man_folder)
    end

    let(:tony) { Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark') }

    shared_examples 'writing entry' do |entry_type, input, expected|
      it "of type #{entry_type} includes expected values" do
        Settings.with_mock_input input do
          subject.command(entry_type, ['tony'])
        end
        verify_answers_propagated(expected, [tony])
      end
    end 

    include_examples 'writing entry', 
      :one_on_one, "\nhere\nMet about goals\n\n\n", ["  here\n", "  Met about goals\n", "  none\n"]
    include_examples 'writing entry', 
      :feedback, "\nnegative\nDid a bad thing\n", ["  negative\n", "  Did a bad thing\n"]
    include_examples 'writing entry',
      :goal, "\ntoday\nBe a good citizen\n", ["  Be a good citizen\n"]
    include_examples 'writing entry',
      :observation, "\nCaught him doing a nice thing\n", ["  Caught him doing a nice thing\n"]
    include_examples 'writing entry',
      :performance_checkpoint, "\nOn track\n", ["  On track\n"]
    include_examples 'writing entry',
      :pto, "today\ntomorrow\nsick\n", ["  sick\n"]
  end

  context 'with multiple people' do
    steve = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
    thor = Employee.new(team: 'Avengers', first: 'Thor', last: 'Odinson')

    before :context do
      [steve, thor].each do |hero|
        FileUtils.mkdir_p File.dirname(hero.file.path)
      end
    end

    after :context do
      FileUtils.rm_r File.dirname(File.dirname(steve.file.path))
    end

    it 'will append the entry to all their logs in the order given' do
      Settings.with_mock_input "\nSpoke about important things\n" do
        subject.command(:observation, %w[thor rogers])
      end

      expected = ["  Thor Odinson, Steve Rogers\n", "  Spoke about important things\n"]
      verify_answers_propagated(expected, [steve, thor])
    end
  end
end