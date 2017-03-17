require './lib/diary_entry.rb'
require './lib/feedback_entry.rb'

describe DiaryEntry do
  it 'should get a feedback entry' do
    expect(DiaryEntry.get('feedback')).to be(FeedbackEntry)
  end
end
