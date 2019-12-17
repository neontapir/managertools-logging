# frozen_string_literal: true

require 'timecop'
Dir.glob('./lib/entries/*_entry.rb', &method(:require))

RSpec.describe DiaryEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('feedback')).to be(FeedbackEntry)
  end

  it 'gets an entry with a space in the name by identifier' do
    expect(DiaryEntry.get('performance-checkpoint')).to be(PerformanceCheckpointEntry)
  end

  context 'with default content' do
    subject(:entry) { PerformanceCheckpointEntry.new }
    let(:entry_date) { Time.local(1999) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it 'renders correctly' do
      expect(entry.render('Test', PerformanceCheckpointEntry)).to eq "=== Test (January  1, 1999, 12:00 AM)\nContent::\n  none\n"
    end

    it 'yields the correct date' do
      expect(entry.date).to eq entry_date
    end
  end

  context 'with a time' do
    subject(:entry) { ObservationEntry.new(datetime: entry_date.to_s) }
    let(:entry_date) { Time.new(2001, 2, 3, 4, 5, 6) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it 'renders correctly' do
      expect(entry.render('Test', ObservationEntry)).to eq "=== Test (February  3, 2001,  4:05 AM)\nContent::\n  none\n"
    end

    it 'yields the correct date' do
      expect(entry.date).to eq entry_date
    end
  end

  context 'with a time and context' do
    subject(:entry) { ObservationEntry.new(datetime: Time.new(2002).to_s, content: 'blah').render('Test', ObservationEntry) }

    it 'renders correctly' do
      expect(entry).to eq "=== Test (January  1, 2002, 12:00 AM)\nContent::\n  blah\n"
    end
  end

  context 'in unimplemented context' do
    # A class that doesn't implement some required methods
    class UnimplementedDiaryEntry < DiaryEntry
    end

    subject(:entry) { UnimplementedDiaryEntry.new(datetime: Time.new(2003)) }

    it 'raises when the template class is not inherited' do
      expect { entry.render('Test') }.to raise_error(NotImplementedError, 'DiaryEntry#elements must be overriden')
    end

    it 'raises when elements is not overriden' do
      expect { entry.elements }.to raise_error(NotImplementedError, 'DiaryEntry#elements must be overriden')
    end

    it 'raises when prompt is not overriden' do
      expect { entry.prompt(nil) }.to raise_error(NotImplementedError, 'DiaryEntry#prompt must be overriden')
    end

    it 'raises when to_s is not overriden' do
      expect { entry.to_s }.to raise_error(NotImplementedError, 'DiaryEntry#to_s must be overriden')
    end
  end

  context 'in improper elements implementation context' do
    # A class that has some unworkable implementations
    class BadElementsArrayDiaryEntry < DiaryEntry
      def prompt(_)
        # do nothing
      end

      def elements
        42 # not enumerable
      end

      def to_s
        # do nothing
      end
    end

    subject(:entry) { BadElementsArrayDiaryEntry.new(datetime: Time.new(2004)) }

    it 'raises when enumerable not returned by elements' do
      expect { entry.render('Test') }.to raise_error(ArgumentError, 'BadElementsArrayDiaryEntry#elements must return an enumerable')
    end
  end
end
