# frozen_string_literal: true

require './lib/settings'
require './lib/entries/pto_entry'
require_relative 'support/shared_contexts'

RSpec.describe PtoEntry do
  context 'during the post-create hook' do
    subject(:entry) { PtoEntry.new }

    include_context 'freeze_time' do
      let(:clock_date) { Time.local(1999) }
    end

    it 'sets the diary data to the start_time' do
      data = entry.post_create({ start_time: 'yesterday', end_time: 'today' })
      expect(data[:datetime].to_s).to include '1998-12-31'
    end

    it 'calculates the duration for a single day vacation correctly' do
      data = entry.post_create({ start_time: 'today', end_time: 'today' })
      expect(data[:duration]).to eq '1 day'
    end

    it 'calculates the duration for a multi-day vacation correctly' do
      data = entry.post_create({ start_time: 'yesterday', end_time: 'today' })
      expect(data[:duration]).to eq '2 days'
    end

    it 'sorts start and end times' do
      data = entry.post_create({ start_time: 'today', end_time: 'yesterday' })
      expect(data[:start_time]).to include 'yesterday'
      expect(data[:end_time]).to include 'today'
    end
  end
end
