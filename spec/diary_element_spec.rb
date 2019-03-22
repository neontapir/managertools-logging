require './lib/diary_element.rb'

describe DiaryElement do
  def proper?(element, key, prompt, default)
    expect(element.key).to be(key)
    expect(element.prompt).to eq prompt
    expect(element.default).to eq default
  end

  it 'creates an element with default values' do
    element = DiaryElement.new(:location)
    proper?(element, :location, 'Location', DiaryElement::DEFAULT_VALUE)
  end

  it 'obtains the specified values' do
    allow(Settings.console).to receive(:ask) { 'plough' }
    element = DiaryElement.new(:xyzzy)
    proper?(element, :xyzzy, 'Xyzzy', DiaryElement::DEFAULT_VALUE)
    expect(element.obtain).to eq 'plough'
  end

  it 'creates an element with specified values' do
    element = DiaryElement.new(:actions, 'Actions to take', 'No actions')
    proper?(element, :actions, 'Actions to take', 'No actions')
  end

  it 'raises if prompt has special characters' do
    expect { DiaryElement.new(:question, 'Questions?', 'No questions') }.to raise_error ArgumentError
  end
end
