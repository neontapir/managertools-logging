require './lib/diary_entry.rb'
require './lib/feedback_entry.rb'

describe DiaryEntry do
  it 'should get a feedback entry' do
    expect(DiaryEntry.get('feedback')).to be(FeedbackEntry)
  end

  it 'should use the current class if the template class is not passed in' do
    entry = DiaryEntry.new({:datetime => Time.new(2002)})
    expect{entry.render('Test')}.to raise_error(ArgumentError, 'DiaryEntry is not a DiaryEntry')
  end

  it 'should raise an error if a DiaryEntry is not passed in' do
    entry = DiaryEntry.new({:datetime => Time.new(2002)})
    expect{entry.render('Test', String)}.to raise_error(ArgumentError, 'String is not a DiaryEntry')
  end

  it 'should render an observation with given time and default content correctly' do
    entry = DiaryEntry.new({:datetime => Time.new(2002)})
    expect(entry.render('Test', ObservationEntry)).to eq("=== Test (January  1, 2002, 12:00 AM)\nContent::\n  none\n")
  end

  it 'should render an observation with given time and content correctly' do
    entry = DiaryEntry.new({:datetime => Time.new(2002), :content => 'blah'})
    expect(entry.render('Test', ObservationEntry)).to eq("=== Test (January  1, 2002, 12:00 AM)\nContent::\n  blah\n")
  end
end
