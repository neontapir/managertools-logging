# frozen_string_literal: true

require './lib/time_extensions'

RSpec.describe TimeExtensions do
  using TimeExtensions

  let (:test_date) { Time.strptime('03-02-2001 04:05:06 PM', '%d-%m-%Y %I:%M:%S %p') }

  it 'formats a short date' do
    expect(test_date.short_date).to eq 'February  3, 2001'
  end

  it 'formats a standard date' do
    expect(test_date.standard_format).to eq 'February  3, 2001,  4:05 PM'
  end
end