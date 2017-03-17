require './lib/diary.rb'
require './lib/feedback_entry.rb'

describe Diary do
  let(:diary_instance) { (Class.new { include Diary }).new }

  context 'in Iron Man context' do
    before(:all) do
      Dir.mkdir('data') unless Dir.exist? 'data'
      Dir.mkdir('data/avengers')
      Dir.mkdir('data/avengers/tony-stark')
    end

    after(:all) do
      Dir.rmdir('data/avengers/tony-stark')
      Dir.rmdir('data/avengers')
    end

    it 'should start a entry with the current date and time' do
      result = diary_instance.started_entry
      expect(result[:content]).to eq('')
      one_second = 1
      expect(result[:datetime].to_i).to be_within(one_second).of Time.now.to_i
    end
  end
end
