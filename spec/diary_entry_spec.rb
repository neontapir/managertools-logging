# frozen_string_literal: true

require 'time'

Dir['./lib/entries/*_entry.rb'].sort.each { |x| require x }
require_relative 'support/shared_contexts'

RSpec.describe DiaryEntry do
  it 'gets an entry by identifier' do
    expect(described_class.get('feedback')).to be(FeedbackEntry)
  end

  it 'gets an entry with a space in the name by identifier' do
    expect(described_class.get('performance-checkpoint')).to be(PerformanceCheckpointEntry)
  end

  context 'when getting inheriting classes' do
    it 'gets itself' do
      expect(described_class.inherited(PerformanceCheckpointEntry)).to include PerformanceCheckpointEntry
    end

    it 'gets classes that inherit from DiaryEntry' do
      throwaway_diary_entry = Class.new(described_class)
      stub_const('ThrowawayDiaryEntry', throwaway_diary_entry)
      expect(described_class.inherited(PerformanceCheckpointEntry)).to include ThrowawayDiaryEntry
    end

    it 'does not get classes that do not inherit from DiaryEntry' do
      expect(described_class.inherited(PerformanceCheckpointEntry)).not_to include String
    end
  end

  context '#populate' do
    subject(:entry) { PerformanceCheckpointEntry.new }

    include_context 'with time frozen' do
      let(:clock_date) { Time.local(1999) }
    end

    let(:populated_data) do
      Settings.with_mock_input("\nGood\n") do
        return entry.populate('John Doe')
      end
    end

    it 'populates data keys as expected' do
      expect(populated_data.keys).to contain_exactly :content, :datetime
    end

    it 'populates content correctly' do
      expect(populated_data[:content]).to eq 'Good'
    end

    it 'populates datetime as expected' do
      expected_time = Time.strptime(populated_data[:datetime], '%Y-%M-%d %H:%M:%S %z')
      expect(expected_time).to be_within(0.01).of(Time.now)
    end

    it 'entry contains the correct date' do
      expect(entry.date).to eq clock_date
    end
  end

  context 'with the current time' do
    subject(:entry) { ObservationEntry.new(datetime: clock_date.to_s) }

    include_context 'with time frozen' do
      let(:clock_date) { Time.new(2001, 2, 3, 4, 5, 6) }
    end

    it 'renders correctly' do
      expect(entry.render('Test', ObservationEntry)).to eq "=== Test (February  3, 2001,  4:05 AM)\nContent::\n  none\n"
    end

    it 'yields the correct date' do
      expect(entry.date).to eq clock_date
    end
  end

  context 'in 2002' do
    subject(:entry) { ObservationEntry.new(datetime: clock_date.to_s, content: 'blah') }

    let(:clock_date) { Time.new(2002) }

    it 'renders correctly' do
      expect(entry.render('Test', ObservationEntry)).to eq "=== Test (January  1, 2002, 12:00 AM)\nContent::\n  blah\n"
    end

    it 'yields the correct date' do
      expect(entry.date).to eq clock_date
    end
  end

  context 'when methods are not implemented' do
    subject(:entry) { unimplemented_diary_entry.new(datetime: Time.new(2003)) }

    let(:unimplemented_diary_entry) do
      # A class that doesn't implement some required methods
      Class.new(described_class)
    end

    before do
      stub_const('UnimplementedDiaryEntry', unimplemented_diary_entry)
    end

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

  context 'with improper elements' do
    # A class that has some unworkable implementations
    subject(:entry) { bad_elements_array_diary_entry.new(datetime: Time.new(2004)) }

    let(:bad_elements_array_diary_entry) do
      Class.new(DiaryEntry) do
        def prompt(_); end

        def to_s(); end

        def elements
          42 # not enumerable
        end
      end
    end

    before do
      stub_const('BadElementsArrayDiaryEntry', bad_elements_array_diary_entry)
    end

    it 'raises when enumerable not returned by elements' do
      expect { entry.render('Test') }.to raise_error(ArgumentError, 'BadElementsArrayDiaryEntry#elements must return an enumerable')
    end
  end

  context 'when looking for equality' do
    subject(:entry) { PerformanceCheckpointEntry.new }

    include_context 'with time frozen' do
      let(:clock_date) { Time.local(1999) }
    end

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
