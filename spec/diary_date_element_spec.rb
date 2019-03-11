require 'timecop'
require './lib/diary_date_element.rb'

describe DiaryDateElement do
  def proper?(element, key, prompt, default)
    expect(element.key).to be(key)
    expect(element.prompt).to eq(prompt)
    expect(element.default).to be_within(2).of(default)
  end

  it 'creates an element with default values' do
    element = DiaryDateElement.new(:datetime)
    proper?(element, :datetime, 'Datetime', Time.now)
  end

  context 'with 1/1/2000 content' do
    entry_date = Time.local(2000, 1, 1)

    before do
      Timecop.freeze(entry_date)
    end

    after do
      Timecop.return
    end

    it 'obtains the relative date' do
      allow(Settings.console).to receive(:ask) { 'yesterday' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', entry_date)
      expect(element.obtain.to_s).to include('1999-12-31')
    end

    it 'obtains the absolute date' do
      allow(Settings.console).to receive(:ask) { '1999-12-01' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', entry_date)
      expect(element.obtain.to_s).to include('1999-12-01')
    end

    it 'obtains now if no date specified' do
      allow(Settings.console).to receive(:ask) { '' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', entry_date)
      expect(element.obtain.to_s).to include('2000-01-01')
    end

    it 'obtains now if an invalid date specified' do
      allow(Settings.console).to receive(:ask) { 'xyzzy' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', entry_date)
      expect(element.obtain.to_s).to include('2000-01-01')
    end
  end

  context 'with 3/1/2000 content' do
    entry_date = Time.local(2000, 3, 1)

    before do
      Timecop.freeze(entry_date)
    end

    after do
      Timecop.return
    end

    it "obtains last year's date if the year isn't specified" do
      allow(Settings.console).to receive(:ask) { '2/20' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', entry_date)
      expect(element.obtain.to_s).to include('2000-02-20')
    end
  end
end
