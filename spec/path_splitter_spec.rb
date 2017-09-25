# frozen_string_literal: true

require './lib/path_splitter.rb'

describe PathSplitter do
  subject { (Class.new { include PathSplitter }).new }

  context 'matching a path' do
    before(:all) do
      FileUtils.mkdir_p('data/justice-league/bruce-wayne')
      FileUtils.mkdir_p('data/justice-league/clark-kent')
    end

    after(:all) do
      FileUtils.remove_dir('data/justice-league')
    end

    it 'does not match an invalid path string and invalid key' do
      expect(subject.matches?('a/b/c', 'x')).to be_falsey
    end

    it 'does not match an invalid path string even with a valid key' do
      expect(subject.matches?('a/b/c', 'a')).to be_falsey
    end

    it 'does not match an invalid key' do
      expect(subject.matches?('data/justice-league/clark-kent', 'bruce')).to be_falsey
    end

    it 'matches an existing path and valid key' do
      expect(subject.matches?('data/justice-league/bruce-wayne', 'bruce')).to be_truthy
    end

    it 'raises on a nil string' do
      expect { subject.matches?(nil, 'x') }.to raise_error ArgumentError, 'Nil path'
    end
  end

  it 'splits a path string' do
    expect(subject.split_path('a/b/c')).to eq(%w[a b c])
  end

  it 'raises splitting a nil string' do
    expect { subject.split_path(nil) }.to raise_error ArgumentError, 'Nil path'
  end
end
