# frozen_string_literal: true

require 'timecop'

RSpec.shared_context 'freeze_time' do
  before do
    Timecop.freeze clock_date
  end

  after do
    Timecop.return
  end
end
