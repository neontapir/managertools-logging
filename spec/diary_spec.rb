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

      def elements
        [
          DiaryElement.new(:xyzzy),
          DiaryElement.new(:wumpus, 'Wumpus', default: 'I feel a draft'),
          DiaryElement.new(:zork, 'Zork', default: 'plover', prompt: nil)
        ]
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

    it 'gets an entry with user input' do
      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) do |prompt|
        case prompt
        when /Xyzzy/ then 'anything'
        end
      end
      entry = subject.get_entry 'Test', 'Tony Stark'
      expect(entry.record).to include(xyzzy: 'anything')
    end

    it 'uses default values when getting an entry' do
      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) {}
      entry = subject.get_entry 'Test', 'Tony Stark'
      expect(entry.record).to include(wumpus: 'I feel a draft')
    end

    it 'overwrites default values with user input' do
      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) do |prompt|
        case prompt
        when /Xyzzy/ then 'anything'
        when /Wumpus/ then 'AHA! You got the wumpus!'
        end
      end
      entry = subject.get_entry 'Test', 'Tony Stark'
      expect(entry.record).to include(wumpus: 'AHA! You got the wumpus!')
    end

    it 'inserts initial values into its record' do
      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) do |prompt|
        case prompt
        when /Xyzzy/ then 'anything'
        end
      end
      entry = subject.get_entry 'Test', 'Tony Stark', oregon_trail: 'BANG'
      expect(entry.record).to include(xyzzy: 'anything')
      expect(entry.record).to include(oregon_trail: 'BANG')
    end

    it 'prioiritizes injected values over user input and default value' do
      expect($stdout).to receive(:puts)
      allow(Settings.console).to receive(:ask) do |prompt|
        case prompt
        when /Zork/ then 'user input value'
        end
      end
      entry = subject.get_entry 'Test', 'Tony Stark', zork: 'The Great Underground Empire'
      expect(entry.record).not_to include(zork: 'plover'), 'failure: used default value'
      expect(entry.record).to include(zork: 'The Great Underground Empire')
    end
  end

  context 'with diary entries that disable prompting', order: :defined do
    subject = (Class.new do
      include Diary
      def template?
        false # interactive mode
      end
    end).new

    # Create a plain type of diary entry
    class TestNoPromptEntry < DiaryEntry
      def prompt(name)
        "Enter your test for #{name}:"
      end

      def elements
        [
          DiaryElement.new(:xyzzy, 'Xyzzy', default: 'adventure', prompt: nil),
          DiaryDateElement.new(:adventure_time, 'Adventure Time', default: Time.local(2000), prompt: nil)
        ]
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

    # NOTE: This feature is useful for derived values, like 'duration' on PtoEntry.
    #   Other tests cover post-prompting data modification.
    it 'uses the default values instead of prompting for entry' do
      expect($stdout).to receive(:puts).with('Enter your test for Tony Stark:')
      expect(Settings.console).not_to receive(:ask)
      entry = subject.get_entry 'Test No Prompt', 'Tony Stark'
      expect(entry.record).to include(xyzzy: 'adventure')
      expect(entry.record[:adventure_time].strftime('%F')).to eq('2000-01-01')
    end
  end
end
