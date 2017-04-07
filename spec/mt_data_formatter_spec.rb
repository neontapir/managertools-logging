require './lib/mt_data_formatter.rb'

describe MtDataFormatter do
  subject { (Class.new { include MtDataFormatter }).new }

  context 'when downcasing strings' do
    it 'should downcase regular strings' do
      expect(subject.unidown('Apple')).to eq('apple')
    end

    it 'should downcase Unicode strings' do
      expect(subject.unidown('Äpple')).to eq('äpple')
    end
  end

  it 'should format a date' do
    test_date = DateTime.strptime('03-02-2001 04:05:06 PM', '%d-%m-%Y %I:%M:%S %p')
    expect(subject.format_date(test_date)).to eq('February  3, 2001,  4:05 PM')
  end

  context 'when stripping out characters' do
    it 'should return the same string if none are present' do
      expect(subject.strip_nonalnum('foo')).to eq('foo')
    end

    it 'should return just alphanumeric characters' do
      expect(subject.strip_nonalnum('f,o;o')).to eq('foo')
    end
  end

  context 'when wrapping a string' do
    it 'should wrap a short string' do
      expect(subject.wrap('foo')).to eq('foo')
    end

    it 'should wrap a string' do
      expect(subject.wrap('hello world it\'s me', 5)).to eq("hello\n" \
      "  world\n" \
      "  it's\n" \
      '  me')
    end

    LOREM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc egestas imperdiet aliquet. Morbi posuere convallis risus, vitae iaculis felis tincidunt sit amet.'.freeze
    it 'should wrap a long string of default length' do
      expected = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc egestas\n" \
      "  imperdiet aliquet. Morbi posuere convallis risus, vitae iaculis felis\n" \
      '  tincidunt sit amet.'
      expect(subject.wrap(LOREM)).to eq(expected)
    end
  end
end
