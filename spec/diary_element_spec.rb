require './lib/diary_element.rb'
require_relative 'captured_io'

describe DiaryElement do
  include CapturedIO

  def is_correct?(element, key, prompt, default)
    expect(element.key).to be(key)
    expect(element.prompt).to eq(prompt)
    expect(element.default).to eq(default)
  end

  it 'creates an element with default values' do
    element = DiaryElement.new(:location)
    is_correct?(element, :location, 'Location', DiaryElement::DEFAULT_VALUE)
  end

  it 'obtains the specified values' do
    input = StringIO.new("plough\n")
    with_captured(input) do |_|
      element = DiaryElement.new(:xyzzy)
      is_correct?(element, :xyzzy, 'Xyzzy', DiaryElement::DEFAULT_VALUE)
      expect(element.obtain).to eq('plough')
    end
  end

  it 'creates an element with specified values' do
    element = DiaryElement.new(:actions, 'Actions to take', 'No actions')
    is_correct?(element, :actions, 'Actions to take', 'No actions')
  end

  it 'raises if prompt has special characters' do
    expect { DiaryElement.new(:question, 'Questions?', 'No questions') }.to raise_error ArgumentError
  end
end
