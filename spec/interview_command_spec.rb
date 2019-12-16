# frozen_string_literal: true

require './lib/employee'
require './lib/commands/interview_command'
require './lib/entries/interview_entry'
require './lib/settings'
require_relative 'file_contents_validation_helper'

RSpec.describe InterviewCommand do
  include FileContentsValidationHelper

  context 'with a known person' do
    before(:each) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
    end

    after(:each) do
      FileUtils.rm_r 'data/avengers'
    end

    let (:tony) { Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark') }

    subject { InterviewCommand.new }

    it 'can write an interview entry' do
      Settings.with_mock_input "\nhere\nSE1\nNick Fury\nEdgy but competent\nHire\n" do
        subject.command ['tony']
      end

      expected = ["  here\n", "  SE1\n", "  Nick Fury\n", "  Edgy but competent\n", "  Hire\n"]
      verify_answers_propagated(expected, [tony])
    end
  end

  context 'with an unknown person' do
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
      Settings.with_mock_input "\n\nSE1\nSteve Rogers\nOne eye not an issue\nHire\n" do
        expect{ subject.command ['nick', 'fury'] }.to output.to_stdout
      end
    end

    after(:each) do
      FileUtils.rm_r "data/#{Settings.candidates_root}"
    end

    subject { InterviewCommand.new }

    it 'will create a new hire' do
      nick = Employee.find('nick')
      fail 'Employee not found' unless nick
      expect(nick.file.path[Settings.candidates_root]).to be_truthy
    end

    it 'will insert an interview entry' do
      nick = Employee.find('nick')
      fail 'Employee not found' unless nick
      
      expected = ["  SE1\n", "  Steve Rogers\n", "  One eye not an issue\n", "  Hire\n"]
      verify_answers_propagated(expected, [nick])
    end

    it 'will use the default VOIP meeting location' do
      nick = Employee.find('nick')
      fail 'Employee not found' unless nick
      
      expected = ["  #{Settings.voip_meeting_default}\n"]
      verify_answers_propagated(expected, [nick])
    end
  end
end