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

  subject(:record_diary_entry) { RecordDiaryEntryCommand.new }

  avengers_folder = File.join(Settings.root, 'avengers')

  after do
    FileUtils.rm_r avengers_folder
  end

  context 'with a single person (Spectrum)' do
    spectrum_folder = File.join(avengers_folder, 'monica-rambeau')

    before do
      FileUtils.mkdir_p spectrum_folder
    end

    let(:spectrum) { Employee.new(team: 'Avengers', first: 'Monica', last: 'Rambeau') }

    shared_examples 'writing entry' do |entry_type, input, expected|
      it "of type #{entry_type} includes expected values" do
        Settings.with_mock_input input do
          record_diary_entry.command(entry_type, ['monica'])
        end
        verify_answers_propagated(expected, [spectrum])
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

  context 'with multiple people (Black Panther, Thor)' do
    black_panther = Employee.new(team: 'Avengers', first: 'Luke', last: 'Charles')
    thor = Employee.new(team: 'Avengers', first: 'Thor', last: 'Odinson')

    before :context do
      [black_panther, thor].each do |hero|
        FileUtils.mkdir_p File.dirname(hero.file.path)
      end
    end

    it 'will append the entry to all their logs in the order given' do
      Settings.with_mock_input "\nSpoke about important things\n" do
        record_diary_entry.command(:observation, %w[thor luke])
      end

      expected = ["  Thor Odinson, Luke Charles\n", "  Spoke about important things\n"]
      verify_answers_propagated(expected, [black_panther, thor])
    end
  end
end
