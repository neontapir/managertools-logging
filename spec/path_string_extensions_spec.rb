# frozen_string_literal: true

require './lib/path_string_extensions'

RSpec.describe PathStringExtensions do
  using described_class

  it 'splits a path string' do
    expect('a/b/c'.split_path).to eq %w[a b c]
  end

  it 'ignores a non-path string' do
    expect('hello'.split_path).to eq %w[hello]
  end

  context 'with #to_path' do
    it 'handles simple names' do
      expect('avengers'.to_path).to eq 'avengers'
    end

    it 'handles hyphens' do
      expect('justice-league'.to_path).to eq 'justice-league'
    end

    it 'handles spaces' do
      expect('League of Extraordinary Gentlemen'.to_path).to eq 'league-of-extraordinary-gentlemen'
    end
  end

  context 'with #path_to_name' do
    it 'handles simple names' do
      expect('avengers'.path_to_name).to eq 'Avengers'
    end

    it 'handles names with spaces' do
      expect('Justice League'.path_to_name).to eq 'Justice League'
    end

    it 'handles hyphens' do
      expect('league-of-extraordinary-gentlemen'.path_to_name).to eq 'League of Extraordinary Gentlemen'
    end
  end
end
