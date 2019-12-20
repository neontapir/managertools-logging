# frozen_string_literal: true

require './lib/employee'
require './lib/commands/interview_command'
require './lib/entries/interview_entry'
require './lib/settings'
require_relative 'file_contents_validation_helper'

RSpec.describe InterviewCommand do
  include FileContentsValidationHelper

  def non_default_values(input)
    input.reject { |i| i == "\n" }.map { |i| "  #{i}" }
  end

  context 'with a known person' do
    input = ["\n", "here\n", "SE1\n", "Nick Fury\n", "Edgy but competent\n", "Hire\n"]
    iron_man_folder = File.join %W[#{Settings.root} avengers tony-stark]

    before do
      FileUtils.mkdir_p iron_man_folder
    end

    after do
      FileUtils.rm_r File.dirname(iron_man_folder)
    end

    let(:tony) { Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark') }

    it 'can write an interview entry' do
      Settings.with_mock_input input do
        subject.command ['tony']
      end

      verify_answers_propagated(non_default_values(input), [tony])
    end
  end

  context 'with an unknown person' do
    input = ["\n", "\n", "SE1\n", "Steve Rogers\n", "One eye not an issue\n", "Hire\n"]

    before do
      Settings.with_mock_input input do
        expect { subject.command ['nick', 'fury'] }.to output.to_stdout
      end
    end

    after do
      FileUtils.rm_r File.join(%W[#{Settings.root} #{Settings.candidates_root}])
    end

    let(:nick) { Employee.find('nick') }

    it 'will create a new hire' do
      fail 'Employee not found' unless nick
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
