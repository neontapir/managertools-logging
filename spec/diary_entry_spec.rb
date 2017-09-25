require 'timecop'
require './lib/diary_entry.rb'
require './lib/feedback_entry.rb'
require './lib/observation_entry.rb'

describe DiaryEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('feedback')).to be(FeedbackEntry)
  end

  context 'with a default content' do
    before do
      Timecop.freeze(Time.local(1999))
    end

    after do
      Timecop.return
    end

    subject { ObservationEntry.new.render('Test', ObservationEntry) }

    it 'renders correctly' do
      is_expected.to eq("=== Test (January  1, 1999, 12:00 AM)\nContent::\n  none\n")
    end
  end

  context 'with a time' do
    subject { ObservationEntry.new({:datetime => Time.new(2002)}).render('Test', ObservationEntry) }

    it 'renders correctly' do
      is_expected.to eq("=== Test (January  1, 2002, 12:00 AM)\nContent::\n  none\n")
    end
  end

  context 'with a time and context' do
    subject { ObservationEntry.new({:datetime => Time.new(2002), :content => 'blah'}).render('Test', ObservationEntry) }

    it 'renders correctly' do
      is_expected.to eq("=== Test (January  1, 2002, 12:00 AM)\nContent::\n  blah\n")
    end
  end

  context 'in unimplemented context' do
    class UnimplementedDiaryEntry < DiaryEntry
    end

    subject { UnimplementedDiaryEntry.new({:datetime => Time.new(2002)}) }

    it 'raises if the template class is not inherited' do
      expect{subject.render('Test')}.to raise_error(NotImplementedError, 'DiaryElement#elements_array must be overriden')
    end

    it 'raises if elements_array is not overriden' do
      expect{subject.elements_array}.to raise_error(NotImplementedError, 'DiaryElement#elements_array must be overriden')
    end

    it 'raises if prompt is not overriden' do
      expect{subject.prompt(nil)}.to raise_error(NotImplementedError, 'DiaryElement#prompt must be overriden')
    end

    it 'raises if to_s is not overriden' do
      expect{subject.to_s}.to raise_error(NotImplementedError, 'DiaryElement#to_s must be overriden')
    end
  end

  context 'in improper elements_array implementation context' do
    class BadElementsArrayDiaryEntry < DiaryEntry
      def prompt(preamble)
        # do nothing
      end

      def elements_array
        42 # not enumerable
      end

      def to_s
        # do nothing
      end
    end

    it 'raises if enumerable not returned by elements_array' do
      entry = BadElementsArrayDiaryEntry.new({:datetime => Time.new(2002)})
      expect{entry.render('Test')}.to raise_error(ArgumentError, 'BadElementsArrayDiaryEntry#elements_array must return an enumerable')
    end
  end

  context 'in improper Time value context' do
    class BadTimeDiaryEntry < DiaryEntry
      def prompt(preamble)
        # do nothing
      end

      def elements_array
        []
      end

      def to_s
        # do nothing
      end
    end

    it 'raises if record[:database] is not a Time' do
      entry = BadTimeDiaryEntry.new({:datetime => 'Nowhen'})
      expect{entry.render('Test')}.to raise_error(ArgumentError, 'record[:database] must be a Time, not a String')
    end
  end
end
