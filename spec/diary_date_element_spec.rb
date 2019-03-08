require 'timecop'
require './lib/diary_date_element.rb'

describe DiaryDateElement do
  def proper?(element, key, prompt, default)
    expect(element.key).to be(key)
    expect(element.prompt).to eq(prompt)
    expect(element.default).to eq(default)
  end

  it 'creates an element with default values' do
    element = DiaryDateElement.new(:datetime)
    proper?(element, :datetime, 'Datetime', DiaryDateElement::DEFAULT_VALUE)
  end

  context 'with default content' do
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
      proper?(element, :datetime, 'Datetime', DiaryDateElement::DEFAULT_VALUE)
      expect(element.obtain.to_s).to include('1999-12-31')
    end

    it 'obtains the absolute date' do
      allow(Settings.console).to receive(:ask) { '1999-12-01' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', DiaryDateElement::DEFAULT_VALUE)
      expect(element.obtain.to_s).to include('1999-12-01')
    end

    it 'obtains now if no date specified' do
      allow(Settings.console).to receive(:ask) { '' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', DiaryDateElement::DEFAULT_VALUE)
      expect(element.obtain.to_s).to include('2000-01-01')
    end

    it 'obtains now if an invalid date specified' do
      allow(Settings.console).to receive(:ask) { 'xyzzy' }
      element = DiaryDateElement.new(:datetime)
      proper?(element, :datetime, 'Datetime', DiaryDateElement::DEFAULT_VALUE)
      expect(element.obtain.to_s).to include('2000-01-01')
    end
  end
end
