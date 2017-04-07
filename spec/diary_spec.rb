require 'trollop'

require './lib/diary.rb'
Dir.glob('./lib/*_entry.rb', &method(:require))

describe Diary do
  let(:diary_instance) { (Class.new do
    include Diary
    def template?
      true # non-interactive mode
    end
  end).new }

  it 'should start a entry with the current date and time' do
    result = diary_instance.started_entry
    expect(result[:content]).to eq('')
    one_second = 1
    expect(result[:datetime].to_i).to be_within(one_second).of Time.now.to_i
  end

  context 'in Iron Man context' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    subject { LogFile.new(Dir.new('data/avengers/tony-stark')) }

    it 'should append an entry to the correct file' do
      old_length = File.size?(subject.path) ? File.size(subject.path) : 0
      _ = diary_instance.record_to_file(:interview, 'tony-stark')
      expect(File.size(subject.path)).to be > old_length
    end
  end
end
