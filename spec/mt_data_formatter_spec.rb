# frozen_string_literal: true

require './lib/mt_data_formatter'

RSpec.describe MtDataFormatter do
  using MtDataFormatter

  context 'when downcasing strings' do
    it 'downcases regular strings' do
      expect('Apple'.unidowncase).to eq 'apple'
    end

    it 'downcases Unicode strings' do
      expect('Äpple'.unidowncase).to eq 'äpple'
    end
  end

  it 'formats a date' do
    test_date = Time.strptime('03-02-2001 04:05:06 PM', '%d-%m-%Y %I:%M:%S %p')
    expect(test_date.standard_format).to eq 'February  3, 2001,  4:05 PM'
  end

  context 'when stripping out characters' do
    it 'returns the same string if none are present' do
      expect('foo'.strip_nonalnum).to eq 'foo'
    end

    it 'returns just alphanumeric characters' do
      expect('f,o;o'.strip_nonalnum).to eq 'foo'
    end
  end

  context 'when wrapping a string' do
    it 'wraps a short string' do
      expect('foo'.wrap).to eq 'foo'
    end

    it 'wraps a multiline string' do
      expect('hello world it\'s me'.wrap(5)).to eq("hello\n" \
      "  world\n" \
      "  it's\n" \
      '  me')
    end

    LOREM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc egestas imperdiet ' \
      'aliquet. Morbi posuere convallis risus, vitae iaculis felis tincidunt sit amet.'
    it 'wraps a long string of default length' do
      expected = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc egestas\n" \
      "  imperdiet aliquet. Morbi posuere convallis risus, vitae iaculis felis\n" \
      '  tincidunt sit amet.'
      expect(LOREM.wrap).to eq expected
    end
  end

  context 'when turning strings to title case' do
    it 'capitalizes the right words' do
      expect('cats in panda suits'.titlecase).to eq 'Cats in Panda Suits'
    end
  end

  context 'when turning strings to name case' do
    it 'capitalizes the right letters' do
      expect('goodwin mcdonald'.to_name).to eq 'Goodwin McDonald'
    end
  end
end
