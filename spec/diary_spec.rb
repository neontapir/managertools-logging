require 'trollop'

require './lib/diary.rb'
Dir.glob('./lib/*_entry.rb', &method(:require))

describe Diary do
  context 'with template' do
    subject = (Class.new do
      include Diary
      def template?
        true # non-interactive mode
      end
    end).new

    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'appends an entry to the correct file' do
      log = LogFile.new(Dir.new('data/avengers/tony-stark'))
      old_length = File.size?(log.path) ? File.size(log.path) : 0
      _ = subject.record_to_file(:interview, 'tony-stark')
      expect(File.size(log.path)).to be > old_length
    end
  end

  context 'with interaction', :order => :defined do
    subject = (Class.new do
      include Diary
      def template?
        false # interactive mode
      end
    end).new

    class TestEntry < DiaryEntry
      def prompt(name)
        "Enter your test for #{name}:"
      end

      def elements_array
        [] # RSpec 3.5 does not support capturing STDIN
      end

      def to_s
        render('Not used')
      end
    end

    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'displays a prompt' do
      # Note that capturing STDOUT this way keeps the file append function from behaving as expected
      expect{_ = subject.record_to_file(:test, 'tony-stark')}
        .to output("Enter your test for Tony Stark:\n")
        .to_stdout
    end
  end
end
