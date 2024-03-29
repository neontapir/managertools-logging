# frozen_string_literal: true

require './lib/employee'
require './lib/log_file'
require './lib/commands/last_entry_command'
require './lib/entries/observation_entry'

RSpec.describe LastEntryCommand do
  context 'with diary entries (Captain Marvel)' do
    captain_marvel_folder = File.join %W[#{Settings.root} avengers carol-danvers]

    subject(:last_entry) { described_class.new }

    before do
      FileUtils.mkdir_p captain_marvel_folder
      captain_marvel = Employee.new(team: 'Avengers', first: 'Carol', last: 'Danvers')
      log_file = captain_marvel.file
      log_file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      log_file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
    end

    after do
      FileUtils.rm_r File.dirname(captain_marvel_folder)
    end

    it 'displays the last entry correctly' do
      expect { last_entry.command 'carol' }.to output("=== Observation (February  4, 2001,  5:06 AM)\nContent::\n  Observation B\n").to_stdout
    end
  end
end
