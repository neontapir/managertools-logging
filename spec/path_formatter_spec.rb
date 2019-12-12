# frozen_string_literal: true

require './lib/path_string_extensions'

RSpec.describe PathStringExtensions do
  using PathStringExtensions

  it 'splits a path string' do
    expect('a/b/c'.split_path).to eq %w[a b c]
  end

  it 'creates the path string correctly' do
    expect('avengers'.to_path).to eq 'avengers'
    expect('justice-league'.to_path).to eq 'justice-league'
    expect('League of Extraordinary Gentlemen'.to_path).to eq 'league-of-extraordinary-gentlemen'
  end

  it 'reconsitutes the name correctly' do
    expect('avengers'.path_to_name).to eq 'Avengers'
    expect('justice-league'.path_to_name).to eq 'Justice League'
    expect('Justice League'.path_to_name).to eq 'Justice League'
    expect('league-of-extraordinary-gentlemen'.path_to_name).to eq 'League of Extraordinary Gentlemen'
  end
end
