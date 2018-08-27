# frozen_string_literal: true

require 'optimist'
require './lib/diary.rb'
Dir.glob('./lib/*_entry.rb', &method(:require))
require_relative 'captured_io'

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
      log = LogFile.new(Dir.new('data/avengers/tony-stark')).path
      old_length = File.size?(log) ? File.size(log) : 0
      _ = subject.record_to_file(:interview, 'tony-stark')
      expect(File.size(log)).to be > old_length
    end
  end

  context 'with interaction', order: :defined do
    include CapturedIO

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
        [DiaryElement.new(:xyzzy)]
      end

      def to_s
        render('Blah blah')
      end
    end

    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'displays a prompt' do
      input = StringIO.new("anything\n")
      with_captured(input) do |output|
        _ = subject.record_to_file(:test, 'tony-stark')
        output.rewind
        expect(output.read).to include("Enter your test for Tony Stark:\n")
      end
    end

    it 'appends an entry' do
      log = LogFile.new(Dir.new('data/avengers/tony-stark')).path
      old_length = File.size?(log) ? File.size(log) : 0

      lorem = StringIO.new("Lorem ipsum dolor sit amet, ea sea integre aliquando cotidieque, est dicta dolores concludaturque ne, his in dolorem volutpat.\nPro in iudico deseruisse, vix feugait accommodare ut, ne iisque appetere delicatissimi nec.")
      with_captured(lorem) do |_|
        _ = subject.record_to_file(:test, 'tony-stark')
        expect(File.size(log)).to be > old_length
      end
    end
  end
end
