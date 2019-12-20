# frozen_string_literal: true

require 'timecop'
require './lib/diary_date_element'
require_relative 'diary_element_test_helper'

RSpec.describe DiaryDateElement do
  include DiaryElementTestHelper

  # validates dates
  def verify_date_correct(request, expected)
    allow(Settings.console).to receive(:ask) { request }
    element = DiaryDateElement.new(:datetime)
    proper?(element, :datetime, 'Datetime', entry_date)
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

  context 'with 1/1/2000 content' do
    let(:entry_date) { Time.local(2000, 1, 1) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it 'obtains the relative date' do
      verify_date_correct('yesterday', '1999-12-31')
    end

    it 'obtains the absolute date' do
      verify_date_correct('1999-12-01', '1999-12-01')
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
    let(:entry_date) { Time.local(2000, 3, 1) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it 'obtains date in past' do
      verify_date_correct('2/20', '2000-02-20')
    end
  end

  context 'with default' do
    let(:entry_date) { Time.local(2000, 1, 1) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
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
    let(:entry_date) { Time.local(2000, 1, 1) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
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
end
