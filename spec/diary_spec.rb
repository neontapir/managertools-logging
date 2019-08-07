# frozen_string_literal: true

require './lib/diary'
Dir.glob('./lib/entries/*_entry.rb', &method(:require))

RSpec.describe Diary do
  context 'with template' do
    subject = (Class.new do
      include Diary
      def template?
        true # non-interactive mode
      end
    end).new

    before(:all) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    it 'appends an entry to the correct file' do
      log = LogFile.new(Dir.new('data/avengers/tony-stark')).path
      old_length = File.size?(log) ? File.size(log) : 0
      _ = subject.record_to_file(:interview, 'tony-stark')
      expect(File.size(log)).to be > old_length
    end
  end

  context 'with interaction', order: :defined do
    subject = (Class.new do
      include Diary
      def template?
        false # interactive mode
      end
    end).new

    # Create a plain type of diary entry
    class TestEntry < DiaryEntry
      def prompt(name)
        "Enter your test for #{name}:"
      end

      def elements_array
        [DiaryElement.new(:xyzzy)]
      end

      def to_s
        render('Blah blah')
      end
    end

    before(:all) do
      FileUtils.mkdir_p 'data/avengers/tony-stark'
    end

    after(:all) do
      FileUtils.rm_r 'data/avengers'
    end

    it 'displays a prompt' do
      expect($stdout).to receive(:puts).with('Enter your test for Tony Stark:')
      allow(Settings.console).to receive(:ask) { 'anything' }
      subject.record_to_file(:test, 'tony-stark')
    end

    it 'appends an entry' do
      log = LogFile.new(Dir.new('data/avengers/tony-stark')).path
      old_length = File.size?(log) ? File.size(log) : 0

      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) { "Lorem ipsum dolor sit amet, ea sea integre aliquando cotidieque, est dicta dolores concludaturque ne, his in dolorem volutpat.\nPro in iudico deseruisse, vix feugait accommodare ut, ne iisque appetere delicatissimi nec." }
      subject.record_to_file(:test, 'tony-stark')
      expect(File.size(log)).to be > old_length
    end

    it 'gets an entry' do
      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) { 'anything' }
      entry = subject.get_entry 'Test', 'Tony Stark'
      expect(entry.record).to include(xyzzy: 'anything')
    end

    it 'gets an entry with initial values' do
      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) { 'anything' }
      entry = subject.get_entry 'Test', 'Tony Stark', plover: 'zork'
      expect(entry.record).to include(xyzzy: 'anything')
      expect(entry.record).to include(plover: 'zork')
    end
  end
end
