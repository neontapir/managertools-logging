# frozen_string_literal: true

require './lib/path_formatter'
require './lib/team'

RSpec.describe Team do
  include PathFormatter

  context 'in initializer context' do
    it 'raises if params hash does not contain a team entry' do
      expect { Team.new({}) }.to raise_error KeyError
    end
  end

  context 'in equality context' do
    let(:avengers) { Team.new(team: 'Avengers') }
    let(:justice_league) { Team.new(team: 'JusticeLeague') }

    it 'finds the same team equal to itself' do
      expect(avengers.eql?(avengers)).to be_truthy
      expect(justice_league.eql?(justice_league)).to be_truthy
    end

    it 'does not find different teams equal to each other' do
      expect(avengers.eql?(justice_league)).to be_falsey
      expect(justice_league.eql?(avengers)).to be_falsey
    end

    it 'gets the same results with the equals operator' do
      expect(justice_league == avengers).to be_falsey
      expect(avengers == justice_league).to be_falsey
    end

    it 'finds teams with different casing in names the same' do
      avengers_miniscule = Team.new(team: 'avengers')
      expect(avengers.eql?(avengers_miniscule)).to be_truthy
    end

    it 'does not find a team equal to a non-team' do
      expect(avengers.eql?('Avengers')).to be_falsey
    end
  end

  it 'does not find a non-existant team' do
    expect(Team.find('xyzzy')).to be_nil
  end

  it 'uses the name as its string representation' do
    avengers = Team.new(team: 'Avengers')
    expect(avengers.to_s).to eq path_to_name('avengers')
  end

  context 'with a typical team (Avengers)' do
    before(:all) do
      Dir.mkdir('data') unless Dir.exist? 'data'
      Dir.mkdir('data/avengers')
      Dir.mkdir('data/avengers/hank-pym')   # Ant Man
      Dir.mkdir('data/avengers/hank-mccoy') # Beast
    end

    after(:all) do
      FileUtils.remove_dir 'data/avengers'
    end

    subject { Team.new(team: 'Avengers') }

    it 'finds the team' do
      team = Team.find('avengers')
      expect(subject).to eq team
    end

    it 'lists its team members' do
      beast = Employee.find('hank-mccoy')
      ant_man = Employee.find('hank-pym')

      expect(subject.members).to contain_exactly(beast, ant_man)
    end

    it 'lists its team members by folder' do
      expect(subject.members_by_folder).to contain_exactly(
        'data/avengers/hank-mccoy',
        'data/avengers/hank-pym'
      )
    end
  end

  context 'with a team name with a space (Justice League)' do
    before(:all) do
      FileUtils.mkdir_p 'data/justice-league/bruce-wayne' # Batman
      FileUtils.mkdir_p 'data/justice-league/clark-kent' # Superman
    end

    after(:all) do
      FileUtils.remove_dir 'data/justice-league'
    end

    subject { Team.new(team: 'Justice League') }

    it 'displays the team as capitalized' do
      expect(subject.to_s).to eq 'Justice League'
    end

    it 'lists its team members by folder' do
      raise IOError, 'No Batman folder' unless Dir.exist? 'data/justice-league/bruce-wayne'
      raise IOError, 'No Superman folder' unless Dir.exist? 'data/justice-league/clark-kent'
      expect(subject.members_by_folder).to contain_exactly(
        'data/justice-league/bruce-wayne',
        'data/justice-league/clark-kent'
      )
    end
  end
end
