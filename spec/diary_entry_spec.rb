# frozen_string_literal: true

require 'time'

Dir['./lib/entries/*_entry.rb'].sort.each(&method(:require))
require_relative 'support/shared_contexts'

RSpec.describe DiaryEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('feedback')).to be(FeedbackEntry)
  end

  it 'gets an entry with a space in the name by identifier' do
    expect(DiaryEntry.get('performance-checkpoint')).to be(PerformanceCheckpointEntry)
  end

  it 'gets inheriting classes' do
    expect(DiaryEntry.inherited(PerformanceCheckpointEntry)).to include PerformanceCheckpointEntry
    expect(DiaryEntry.inherited(PerformanceCheckpointEntry)).not_to include String

    class ThrowawayDiaryEntry < DiaryEntry; end

    expect(DiaryEntry.inherited(PerformanceCheckpointEntry)).to include ThrowawayDiaryEntry
  end

  context 'with default content' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.local(1999) }
    end

    subject(:entry) { PerformanceCheckpointEntry.new }

    it 'renders correctly' do
      expect(entry.render('Test', PerformanceCheckpointEntry)).to eq "=== Test (January  1, 1999, 12:00 AM)\nContent::\n  none\n"
    end

    it 'populates as expected' do
      Settings.with_mock_input("\nGood\n") do
        data = entry.populate('John Doe')
        expect(data.keys).to contain_exactly :content, :datetime
        expect(data[:content]).to eq 'Good'
        expected_time = Time.strptime(data[:datetime], '%Y-%M-%d %H:%M:%S %z')
        expect(expected_time).to be_within(0.01).of(Time.now)
      end
    end

    it 'yields the correct date' do
      expect(entry.date).to eq clock_date
    end
  end

  context 'with the current time' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.new(2001, 2, 3, 4, 5, 6) }
    end

    subject(:entry) { ObservationEntry.new(datetime: clock_date.to_s) }

    it 'renders correctly' do
      expect(entry.render('Test', ObservationEntry)).to eq "=== Test (February  3, 2001,  4:05 AM)\nContent::\n  none\n"
    end

    it 'yields the correct date' do
      expect(entry.date).to eq clock_date
    end
  end

  context 'with a past time' do
    subject(:entry) { ObservationEntry.new(datetime: clock_date.to_s, content: 'blah') }
    let(:clock_date) { Time.new(2002) }

    it 'renders correctly' do
      expect(entry.render('Test', ObservationEntry)).to eq "=== Test (January  1, 2002, 12:00 AM)\nContent::\n  blah\n"
    end

    it 'yields the correct date' do
      expect(entry.date).to eq clock_date
    end
  end

  context 'in unimplemented context' do
    # A class that doesn't implement some required methods
    class UnimplementedDiaryEntry < DiaryEntry
    end

    subject(:entry) { UnimplementedDiaryEntry.new(datetime: Time.new(2003)) }

    it 'raises when the template class is not inherited' do
      expect { entry.render('Test') }.to raise_error AttrExtras::MethodNotImplementedError
    end

    it 'raises when elements is not overriden' do
      expect { entry.elements }.to raise_error AttrExtras::MethodNotImplementedError
    end

    it 'raises when prompt is not overriden' do
      expect { entry.prompt(nil) }.to raise_error AttrExtras::MethodNotImplementedError
    end
  end

  context 'in improper elements implementation context' do
    # A class that has some unworkable implementations
    class BadElementsArrayDiaryEntry < DiaryEntry
      def prompt(_); end
      def to_s(); end

      def elements
        42 # not enumerable
      end
    end

    subject(:entry) { BadElementsArrayDiaryEntry.new(datetime: Time.new(2004)) }

    it 'raises when enumerable not returned by elements' do
      expect { entry.render('Test') }.to raise_error(ArgumentError, 'BadElementsArrayDiaryEntry#elements must return an enumerable')
    end
  end

  context 'with default content' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.local(1999) }
    end

    subject(:entry) { PerformanceCheckpointEntry.new }

    it 'implements equality' do
      expect(entry).to eq PerformanceCheckpointEntry.new
    end

    it 'finds a different record unequal' do
      other = PerformanceCheckpointEntry.new
      Settings.with_mock_input("\nGood\n") do
        other.populate('John Doe')
      end
      expect(entry).not_to eq other
    end
  end
end
