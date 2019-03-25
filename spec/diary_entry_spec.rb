# frozen_string_literal: true

require 'timecop'
Dir.glob('./lib/*_entry.rb', &method(:require))

describe DiaryEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('feedback')).to be(FeedbackEntry)
  end

  it 'gets an entry with a space in the name by identifier' do
    expect(DiaryEntry.get('performance-checkpoint')).to be(PerformanceCheckpointEntry)
  end

  context 'with default content' do
    let (:entry_date) { Time.local(1999) }

    before do
      Timecop.freeze entry_date
    end
  
    after do
      Timecop.return
    end

    subject { ObservationEntry.new }

    it 'renders correctly' do
      expect(subject.render('Test', ObservationEntry)).to eq "=== Test (January  1, 1999, 12:00 AM)\nContent::\n  none\n"
    end

    it 'yields the correct date' do
      expect(subject.date).to eq entry_date
    end
  end

  context 'with a time' do
    let (:entry_date) { Time.new(2001, 2, 3, 4, 5, 6) }

    before do
      Timecop.freeze entry_date
    end
  
    after do
      Timecop.return
    end
    
    subject { ObservationEntry.new(datetime: entry_date.to_s) }

    it 'renders correctly' do
      expect(subject.render('Test', ObservationEntry)).to eq "=== Test (February  3, 2001,  4:05 AM)\nContent::\n  none\n"
    end

    it 'yields the correct date' do
      expect(subject.date).to eq entry_date
    end
  end

  context 'with a time and context' do
    subject { ObservationEntry.new(datetime: Time.new(2002).to_s, content: 'blah').render('Test', ObservationEntry) }

    it 'renders correctly' do
      is_expected.to eq "=== Test (January  1, 2002, 12:00 AM)\nContent::\n  blah\n"
    end
  end

  context 'in unimplemented context' do
    class UnimplementedDiaryEntry < DiaryEntry
    end

    subject { UnimplementedDiaryEntry.new(datetime: Time.new(2003)) }

    it 'raises if the template class is not inherited' do
      expect { subject.render('Test') }.to raise_error(NotImplementedError, 'DiaryEntry#elements_array must be overriden')
    end

    it 'raises if elements_array is not overriden' do
      expect { subject.elements_array }.to raise_error(NotImplementedError, 'DiaryEntry#elements_array must be overriden')
    end

    it 'raises if prompt is not overriden' do
      expect { subject.prompt(nil) }.to raise_error(NotImplementedError, 'DiaryEntry#prompt must be overriden')
    end

    it 'raises if to_s is not overriden' do
      expect { subject.to_s }.to raise_error(NotImplementedError, 'DiaryEntry#to_s must be overriden')
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
      entry = BadElementsArrayDiaryEntry.new(datetime: Time.new(2004))
      expect { entry.render('Test') }.to raise_error(ArgumentError, 'BadElementsArrayDiaryEntry#elements_array must return an enumerable')
    end
  end
end
