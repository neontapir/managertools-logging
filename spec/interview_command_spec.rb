# frozen_string_literal: true

require './lib/employee'
require './lib/commands/interview_command'
require './lib/entries/interview_entry'
require './lib/settings'
require_relative 'file_contents_validation_helper'

RSpec.describe InterviewCommand do
  include FileContentsValidationHelper

  context 'with a known person' do
    INPUT = ["\n", "here\n", "SE1\n", "Nick Fury\n", "Edgy but competent\n", "Hire\n"]
    iron_man_folder = File.join(%W[#{Settings.root} avengers tony-stark])

    before(:each) do
      FileUtils.mkdir_p iron_man_folder
    end

    after(:each) do
      FileUtils.rm_r File.dirname(iron_man_folder)
    end

    let (:tony) { Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark') }

    subject { InterviewCommand.new }

    it 'can write an interview entry' do
      Settings.with_mock_input INPUT do
        subject.command ['tony']
      end

      expected_values = INPUT.reject{ |i| i == "\n" }.map{ |i| "  #{i}" }
      verify_answers_propagated(expected_values, [tony])
    end
  end

  context 'with an unknown person' do
    INPUT = ["\n", "\n", "SE1\n", "Steve Rogers\n", "One eye not an issue\n", "Hire\n"]
    before(:each) do
      # allow(Settings.console).to receive(:print)
      # allow(Settings.console).to receive(:say)
      # allow(Settings.console).to receive(:ask).and_return(nil) # default
      # allow(Settings.console).to receive(:ask).with(/Position/).and_return('SE1')
      # allow(Settings.console).to receive(:ask).with(/Other panel/).and_return('Steve Rogers')
      # allow(Settings.console).to receive(:ask).with(/Notes/).and_return('One eye not an issue')
      # allow(Settings.console).to receive(:ask).with(/Recommendation/).and_return('Hire')
      # Settings.with_mock_input do
      #   subject.command ['nick', 'fury']
      # end
      Settings.with_mock_input INPUT do
        expect{ subject.command ['nick', 'fury'] }.to output.to_stdout
      end
    end

    after(:each) do
      FileUtils.rm_r File.join(%W[#{Settings.root} #{Settings.candidates_root}])
    end

    subject { InterviewCommand.new }
    let(:nick) { Employee.find('nick') }

    it 'will create a new hire' do
      fail 'Employee not found' unless nick
      expect(nick.file.path[Settings.candidates_root]).to be_truthy
    end

    it 'will insert an interview entry' do
      # non_defaults = ["  SE1\n", "  Steve Rogers\n", "  One eye not an issue\n", "  Hire\n"]
      non_defaults = INPUT.reject{ |i| i == "\n" }.map{ |i| "  #{i}" }
      verify_answers_propagated(non_defaults, [nick])
    end

    it 'will use the default VOIP meeting location' do
      expected = ["  #{Settings.voip_meeting_default}\n"]
      verify_answers_propagated(expected, [nick])
    end
  end
end
