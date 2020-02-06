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
    element = DiaryDateElement.new(:datetime)
    proper?(element, :datetime, 'Datetime', Time.now)
  end

  it 'creates an element with prompt specified' do
    element = DiaryDateElement.new(:the_time, 'My date')
    proper?(element, :the_time, 'My date', Time.now)
  end

  context 'with a given date (1/1/2000)' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.local(2000, 1, 1) }
    end

    context 'when valid date specified' do
      it 'obtains the relative date' do
        verify_date_correct('yesterday', '1999-12-31')
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
    include_context 'freeze_time' do
      let(:clock_date) { Time.local(2000, 3, 1) }
    end

    it 'obtains date in past' do
      verify_date_correct('2/20', '2000-02-20')
    end
  end

  context 'using the default attribute' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.local(2000, 1, 1) }
    end

    it 'uses now' do
      element = DiaryDateElement.new(:datetime, 'Datetime')
      expect(element.default.to_s).to include('2000-01-01')
    end

    it 'obtains the date with the default format' do
      element = DiaryDateElement.new(:datetime, 'Datetime', default: Time.local(1999, 12, 25))
      expect(element.default.to_s).to include('1999-12-25')
    end
  end

  context 'using formatting' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.local(2000, 1, 1) }
    end

    it 'obtains the date with the default format', :aggregate_failures do
      allow(Settings.console).to receive(:ask) { 'yesterday' }
      element = DiaryDateElement.new(:datetime)
      expected = element.obtain.to_s
      expect(expected).to include('1999-12-31 12:00:00')

      gmt_offset = Time.now.strftime('%z') # '-0700'
      expect(expected).to include(gmt_offset)
    end

    it 'obtains the date with a specified format' do
      allow(Settings.console).to receive(:ask) { 'yesterday' }
      element = DiaryDateElement.new(:datetime, 'Datetime', formatter: ->x { x.strftime '%B %e, %Y' })
      expect(element.obtain.to_s).to include('December 31, 1999')
    end
  end

  context 'with 6/29/2007 content' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.local(2007, 6, 29) }
    end

    subject { DiaryDateElement.new(:datetime, 'Datetime') }

    it 'implements equality' do
      equal = DiaryDateElement.new(:datetime, 'Datetime')
      is_expected.to eq equal
    end

    it 'finds a different key unequal' do
      different_key = DiaryDateElement.new(:hammer_time, 'Datetime')
      is_expected.not_to eq different_key
    end

    it 'finds a different label unequal' do
      different_label = DiaryDateElement.new(:datetime, 'Hammer time')
      is_expected.not_to eq different_label
    end

    it 'finds a different value unequal' do
      different_value = DiaryDateElement.new(:datetime, 'Datetime', default: Time.local(1999, 12, 25))
      is_expected.not_to eq different_value
    end
  end
end
