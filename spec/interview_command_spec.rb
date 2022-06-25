# frozen_string_literal: true

require './lib/employee'
require './lib/commands/interview_command'
require './lib/entries/interview_entry'
require './lib/settings'
require_relative 'file_contents_validation_helper'

RSpec.describe InterviewCommand do
  include FileContentsValidationHelper

  subject(:interview) { described_class.new }

  def non_default_values(input)
    input.reject { |i| i == "\n" }.map { |i| "  #{i}" }
  end

  context 'with a known person (Hellcat)' do
    input = ["\n", "here\n", "SE1\n", "Nick Fury\n", "Scientist and pyschic\n", "Hire\n"]
    hellcat_folder = File.join %W[#{Settings.root} avengers patsy-walker]

    before do
      FileUtils.mkdir_p hellcat_folder
    end

    after do
      FileUtils.rm_r File.dirname(hellcat_folder)
    end

    let(:hellcat) { Employee.new(team: 'Avengers', first: 'Patsy', last: 'Walker') }

    it 'can write an interview entry' do
      Settings.with_mock_input input do
        interview.command ['patsy']
      end

      verify_answers_propagated(non_default_values(input), [hellcat])
    end
  end

  context 'with a previously unknown person (Nick Fury)' do
    input = ["\n", "\n", "SE1\n", "Steve Rogers\n", "One eye not an issue\n", "Hire\n"]

    before do
      Settings.with_mock_input input do
        expect { interview.command %w[nick fury] }.to output.to_stdout
      end
    end

    after do
      FileUtils.rm_r File.join(Settings.root, Settings.candidates_root)
    end

    let(:nick) { Employee.find('nick') }

    it 'will create a new hire' do
      raise 'Employee not found' unless nick

      expect(nick.file.path[Settings.candidates_root]).to be_truthy
    end

    it 'will insert an interview entry' do
      verify_answers_propagated(non_default_values(input), [nick])
    end

    it 'will use the default VOIP meeting location' do
      expected = ["  #{Settings.voip_meeting_default}\n"]
      verify_answers_propagated(expected, [nick])
    end
  end
end
