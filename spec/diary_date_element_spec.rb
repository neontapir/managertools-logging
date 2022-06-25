# frozen_string_literal: true

require './lib/diary_date_element'
require_relative 'diary_element_test_helper'
require_relative 'support/shared_contexts'

RSpec.describe DiaryDateElement do
  include DiaryElementTestHelper

  # validates dates
  def verify_date_correct(request, expected)
    allow(Settings.console).to receive(:ask) { request }
    element = DiaryDateElement.new(:datetime)
    proper?(element, :datetime, 'Datetime', clock_date)
    expect(element.obtain.to_s).to include(expected)
  end

  it 'creates an element with default values' do
    element = described_class.new(:datetime)
    proper?(element, :datetime, 'Datetime', Time.now)
  end

  it 'creates an element with prompt specified' do
    element = described_class.new(:the_time, 'My date')
    proper?(element, :the_time, 'My date', Time.now)
  end

  context 'with a given morning date (1/1/2000 10am)' do
    include_context 'with time frozen' do
      let(:clock_date) { Time.local(2000, 1, 1, 10) }
    end

    context 'when valid date specified' do
      it 'parses "now" as expected' do
        allow(Settings.console).to receive(:ask).and_return('now')
        element = described_class.new(:datetime)
        proper?(element, :datetime, 'Datetime', clock_date)
        expect(element.obtain.to_s).to eq(clock_date.to_s)
      end

      it 'parses "today" as "today noon" when noon has not yet happened' do
        allow(Settings.console).to receive(:ask).and_return('today')
        element = described_class.new(:datetime)
        proper?(element, :datetime, 'Datetime', clock_date)
        expect(element.obtain.to_s).to start_with('2000-01-01 12:00:00')
      end
    end
  end

  context 'with a given afternoon date (1/1/2000 2pm)' do
    include_context 'with time frozen' do
      let(:clock_date) { Time.local(2000, 1, 1, 14) }
    end

    context 'when valid date specified' do
      it 'obtains the relative date' do
        verify_date_correct('yesterday', '1999-12-31')
      end

      it 'parses "now" as expected' do
        allow(Settings.console).to receive(:ask).and_return('now')
        element = described_class.new(:datetime)
        proper?(element, :datetime, 'Datetime', clock_date)
        expect(element.obtain.to_s).to start_with('2000-01-01 14:00:00')
      end

      it 'parses "today" as "today noon" when noon has passed' do
        allow(Settings.console).to receive(:ask).and_return('today')
        element = described_class.new(:datetime)
        proper?(element, :datetime, 'Datetime', clock_date)
        expect(element.obtain.to_s).to start_with('2000-01-01 12:00:00')
      end

      it 'obtains the absolute date' do
        verify_date_correct('1999-12-01', '1999-12-01')
      end
    end

    context 'when no date specified' do
      it 'obtains now' do
        verify_date_correct('', '2000-01-01')
      end
    end

    context 'when invalid date specified' do
      it 'obtains now' do
        verify_date_correct('xyzzy', '2000-01-01')
      end
    end
  end

  context 'when year is not specified' do
    include_context 'with time frozen' do
      let(:clock_date) { Time.local(2000, 3, 1) }
    end

    it 'obtains date in past' do
      verify_date_correct('2/20', '2000-02-20')
    end
  end

  context 'with the default attribute' do
    include_context 'with time frozen' do
      let(:clock_date) { Time.local(2000, 1, 1) }
    end

    it 'uses now' do
      element = described_class.new(:datetime, 'Datetime')
      expect(element.default.to_s).to include('2000-01-01')
    end

    it 'obtains the date with the default format' do
      element = described_class.new(:datetime, 'Datetime', default: Time.local(1999, 12, 25))
      expect(element.default.to_s).to include('1999-12-25')
    end
  end

  context 'with formatting' do
    include_context 'with time frozen' do
      let(:clock_date) { Time.local(2000, 1, 1) }
    end

    it 'obtains the date with the default format', :aggregate_failures do
      allow(Settings.console).to receive(:ask).and_return('yesterday')
      element = described_class.new(:datetime)
      expected = element.obtain.to_s
      expect(expected).to include('1999-12-31 12:00:00')

      gmt_offset = Time.now.strftime('%z') # '-0700'
      expect(expected).to include(gmt_offset)
    end

    it 'obtains the date with a specified format' do
      allow(Settings.console).to receive(:ask).and_return('yesterday')
      element = described_class.new(:datetime, 'Datetime', formatter: ->x { x.strftime '%B %e, %Y' })
      expect(element.obtain.to_s).to include('December 31, 1999')
    end
  end

  context 'with 6/29/2007 content' do
    subject(:date_element) { described_class.new(:datetime, 'Datetime') }

    include_context 'with time frozen' do
      let(:clock_date) { Time.local(2007, 6, 29) }
    end

    it 'implements equality' do
      equal = described_class.new(:datetime, 'Datetime')
      expect(date_element).to eq equal
    end

    it 'finds a different key unequal' do
      different_key = described_class.new(:hammer_time, 'Datetime')
      expect(date_element).not_to eq different_key
    end

    it 'finds a different label unequal' do
      different_label = described_class.new(:datetime, 'Hammer time')
      expect(date_element).not_to eq different_label
    end

    it 'finds a different value unequal' do
      different_value = described_class.new(:datetime, 'Datetime', default: Time.local(1999, 12, 25))
      expect(date_element).not_to eq different_value
    end
  end
end
