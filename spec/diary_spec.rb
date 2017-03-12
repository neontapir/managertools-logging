require './lib/diary.rb'
require './lib/feedback_entry.rb'

describe Diary do
  let(:diary_instance) { (Class.new { include Diary }).new }

  it 'should get a feedback entry' do
    expect(diary_instance.get_entry_type('feedback')).to be(FeedbackEntry)
  end

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

    it 'should get the employee file' do
      log = diary_instance.get_file_by_person 'tony'
      expect(log.to_s).to eq('data/avengers/tony-stark/log.adoc')
    end

    it 'should get the team' do
      team = diary_instance.get_team 'avengers'
      expect(team.to_s).to eq('Avengers')
    end

    it 'should create a blank entry' do
      result = diary_instance.create_blank_entry('Feedback')
      expect(result[:content]).to eq('')
      one_second = 1
      expect(result[:datetime].to_i).to be_within(one_second).of Time.now.to_i
    end
  end
end
