# frozen_string_literal: true

require './lib/path_string_extensions'
require './lib/team'

RSpec.describe Team do
  using PathStringExtensions

  context 'with a typical team (Avengers)' do
    subject(:avengers) { Team.new(team: 'Avengers') }
    ant_man_folder = File.join %W[#{Settings.root} avengers hank-pym]
    beast_folder = File.join %W[#{Settings.root} avengers hank-mccoy]

    before :context do
      [ant_man_folder, beast_folder].each do |folder|
        FileUtils.mkdir_p folder
      end
    end

    after :context do
      FileUtils.rm_r File.dirname(ant_man_folder)
    end

    it 'finds the team' do
      expect(avengers).to eq Team.find('avengers')
    end

    it {
      is_expected.to have_attributes(
        path: 'avengers',
        to_s: 'Avengers',
      )
    }

    it 'uses the name as its string representation' do
      expect(avengers.to_s).to eq 'avengers'.path_to_name
    end

    it 'lists its team members' do
      ant_man = Employee.find('hank-pym')
      beast = Employee.find('hank-mccoy')

      expect(avengers.members).to contain_exactly(beast, ant_man)
    end

    it 'lists its team members by folder' do
      expect(avengers.members_by_folder).to contain_exactly(ant_man_folder, beast_folder)
    end

    it 'implements equality' do
      expect(avengers).to eq Team.new(team: 'avengers')
    end
  end

  context 'with a team name with a space (Justice League)' do
    subject(:justice_league) { Team.new(team: 'Justice League') }
    batman_folder = File.join %W[#{Settings.root} justice-league bruce-wayne]
    superman_folder = File.join %W[#{Settings.root} justice-league clark-kent]

    before :context do
      [batman_folder, superman_folder].each do |folder|
        FileUtils.mkdir_p folder
      end
    end

    after :context do
      FileUtils.remove_dir File.dirname(batman_folder)
    end

    it 'displays the team as capitalized' do
      expect(justice_league.to_s).to eq 'Justice League'
    end

    it 'lists its team members by folder' do
      expect(Dir).to exist batman_folder
      expect(Dir).to exist superman_folder
      expect(justice_league.members_by_folder).to contain_exactly(batman_folder, superman_folder)
    end
  end

  context 'when finding' do
    it 'does not find a non-existant team' do
      expect(Team.find('xyzzy')).to be_nil
    end
  end

  context 'when determining equality' do
    subject(:avengers) { Team.new(team: 'Avengers') }
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
      expect(avengers == justice_league).to be_falsey
      expect(justice_league == avengers).to be_falsey
    end

    it 'finds teams with different casing in names the same' do
      avengers_miniscule = Team.new(team: 'avengers')
      expect(avengers.eql?(avengers_miniscule)).to be_truthy
    end

    it 'does not find a team equal to a non-team' do
      expect(avengers.eql?('Avengers')).to be_falsey
    end
  end

  context 'abnromal usage' do
    it 'the initializer raises for empty hash' do
      expect { Team.new() }.to raise_error ArgumentError
    end

    it 'the initializer raises for nil team' do
      expect { Team.new(team: nil) }.to raise_error ArgumentError
    end

    it 'the initializer raises for empty team' do
      expect { Team.new(team: '') }.to raise_error ArgumentError
    end
  end
end
