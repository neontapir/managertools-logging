require 'timecop'
require './lib/diary_date_element.rb'

describe DiaryDateElement do
  def proper?(element, key, prompt, default)
    expect(element.key).to be(key)
    expect(element.prompt).to eq prompt
    expect(element.default).to be_within(2).of(default)
  end

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
    let (:entry_date) { Time.local(2000, 1, 1) }

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

    it 'obtains now if no date specified' do
      verify_date_correct('', '2000-01-01')
    end

    it 'obtains now if an invalid date specified' do
      verify_date_correct('xyzzy', '2000-01-01')
    end
  end

  context 'with 3/1/2000 content' do
    let (:entry_date) { Time.local(2000, 3, 1) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it "obtains date in past if the year isn't specified" do
      verify_date_correct('2/20', '2000-02-20')
    end
  end

  context 'using formatting' do
    let (:entry_date) { Time.local(2000, 1, 1) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it 'obtains the date with the default format' do
      allow(Settings.console).to receive(:ask) { 'yesterday' }
      element = DiaryDateElement.new(:datetime)
      expected = element.obtain.to_s
      expect(expected).to include('1999-12-31 12:00:00')
      
      gmt_offset = Time.now.strftime('%z') # '-0700'
      expect(expected).to include(gmt_offset) 
    end

    it 'obtains the date with a specified format' do
      allow(Settings.console).to receive(:ask) { 'yesterday' }
      element = DiaryDateElement.new(:datetime, 'Datetime', -> x { x.strftime '%B %e, %Y' })
      expect(element.obtain.to_s).to include('December 31, 1999')
    end
  end
end
