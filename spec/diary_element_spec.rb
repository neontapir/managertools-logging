require './lib/diary_element.rb'

describe DiaryElement do
  it 'should create an element with default values' do
    element = DiaryElement.new(:location)
    expect(element.key).to be(:location)
    expect(element.prompt).to eq("Location")
    expect(element.default).to eq(DiaryElement::NONE)
  end

  it 'should create an element with specified values' do
    element = DiaryElement.new(:actions, 'Actions to take', 'No actions')
    expect(element.key).to be(:actions)
    expect(element.prompt).to eq('Actions to take')
    expect(element.default).to eq('No actions')
  end

  it 'should fail if prompt has special characters' do
    expect{DiaryElement.new(:question, 'Questions?', 'No questions')}.to raise_error ArgumentError
  end
end
