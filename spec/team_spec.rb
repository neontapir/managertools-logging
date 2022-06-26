# frozen_string_literal: true

require './lib/path_string_extensions'
require './lib/team'

RSpec.describe Team do
  using PathStringExtensions

  context 'with a typical team (Avengers)' do
    subject(:avengers) { described_class.new(team: 'Avengers') }

    ant_man_folder = File.join %W[#{Settings.root} avengers hank-pym]
    beast_folder = File.join %W[#{Settings.root} avengers hank-mccoy]

    before do
      [ant_man_folder, beast_folder].each do |folder|
        FileUtils.mkdir_p folder
      end
    end

    after do
      FileUtils.rm_r File.dirname(ant_man_folder)
    end

    it 'finds the team' do
      expect(avengers).to eq described_class.find('avengers')
    end

    it {
      expect(avengers).to have_attributes(
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
      expect(avengers).to eq described_class.new(team: 'avengers')
    end
  end

  context 'with a team name with a space (Justice League)' do
    subject(:justice_league) { described_class.new(team: 'Justice League') }

    batman_folder = File.join %W[#{Settings.root} justice-league bruce-wayne]
    superman_folder = File.join %W[#{Settings.root} justice-league clark-kent]

    before do
      [batman_folder, superman_folder].each do |folder|
        FileUtils.mkdir_p folder
      end
    end

    after do
      FileUtils.remove_dir File.dirname(batman_folder)
    end

    it 'displays the team as capitalized' do
      expect(justice_league.to_s).to eq 'Justice League'
    end

    it 'lists its team members by folder' do
      expect(justice_league.members_by_folder).to contain_exactly(batman_folder, superman_folder)
    end
  end

  context 'when finding' do
    it 'does not find a non-existant team' do
      expect(described_class.find('xyzzy')).to be_nil
    end
  end

  context 'when determining equality' do
    subject(:avengers) { described_class.new(team: 'Avengers') }

    let(:justice_league) { described_class.new(team: 'JusticeLeague') }

    it 'finds the same team equal to itself' do
      expect(avengers).to be_eql(avengers)
      expect(justice_league).to be_eql(justice_league)
    end

    it 'does not find different teams equal to each other' do
      expect(avengers).not_to be_eql(justice_league)
      expect(justice_league).not_to be_eql(avengers)
    end

    it 'gets the same results with the equals operator' do
      expect(avengers == justice_league).to be_falsey
      expect(justice_league == avengers).to be_falsey
    end

    it 'finds teams with different casing in names the same' do
      avengers_miniscule = described_class.new(team: 'avengers')
      expect(avengers).to be_eql(avengers_miniscule)
    end

    it 'does not find a team equal to a non-team' do
      expect(avengers).not_to be_eql('Avengers')
    end
  end

  context 'when used abnormally' do
    it 'the initializer raises for empty hash' do
      expect { described_class.new }.to raise_error ArgumentError
    end

    it 'the initializer raises for nil team' do
      expect { described_class.new(team: nil) }.to raise_error ArgumentError
    end

    it 'the initializer raises for empty team' do
      expect { described_class.new(team: '') }.to raise_error ArgumentError
    end
  end
end
