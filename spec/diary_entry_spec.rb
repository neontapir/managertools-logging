require './lib/diary_entry.rb'
require './lib/feedback_entry.rb'
require './lib/observation_entry.rb'

describe DiaryEntry do
  context 'in typical context' do
    it 'should get a feedback entry' do
      expect(DiaryEntry.get('feedback')).to be(FeedbackEntry)
    end

    it 'should render an observation with given time and default content correctly' do
      entry = ObservationEntry.new({:datetime => Time.new(2002)})
      expect(entry.render('Test', ObservationEntry)).to eq("=== Test (January  1, 2002, 12:00 AM)\nContent::\n  none\n")
    end

    it 'should render an observation with given time and content correctly' do
      entry = ObservationEntry.new({:datetime => Time.new(2002), :content => 'blah'})
      expect(entry.render('Test', ObservationEntry)).to eq("=== Test (January  1, 2002, 12:00 AM)\nContent::\n  blah\n")
    end
  end

  context 'in unimplemented context' do
    class UnimplementedDiaryEntry < DiaryEntry
    end

    subject { UnimplementedDiaryEntry.new({:datetime => Time.new(2002)}) }

    it 'should raise if the template class is not inherited' do
      expect{subject.render('Test')}.to raise_error(NotImplementedError, 'DiaryElement#elements_array must be overriden')
    end

    it 'should raise if elements_array is not overriden' do
      expect{subject.elements_array}.to raise_error(NotImplementedError, 'DiaryElement#elements_array must be overriden')
    end

    it 'should raise if prompt is not overriden' do
      expect{subject.prompt(nil)}.to raise_error(NotImplementedError, 'DiaryElement#prompt must be overriden')
    end

    it 'should raise if to_s is not overriden' do
      expect{subject.to_s}.to raise_error(NotImplementedError, 'DiaryElement#to_s must be overriden')
    end
  end

  context 'in improper implementation context' do
    class BadElementsArrayDiaryEntry < DiaryEntry
      def prompt(preamble)
        # do nothing
      end

      def elements_array
        # do nothing
      end

      def to_s
        # do nothing
      end
    end

    it 'should fail if the implementer does not return an enumerable for an elements_array' do
      entry = BadElementsArrayDiaryEntry.new({:datetime => Time.new(2002)})
      expect{entry.render('Test')}.to raise_error(ArgumentError, 'BadElementsArrayDiaryEntry#elements_array must return an enumerable')
    end
  end
end
