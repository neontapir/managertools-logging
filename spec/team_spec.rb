# frozen_string_literal: true

require './lib/path_string_extensions'
require './lib/team'

RSpec.describe Team do
  using PathStringExtensions

  context 'params hash does not contain a team entry' do
    it 'the initializer raises' do
      expect { Team.new({}) }.to raise_error KeyError
    end
  end

  context 'in string representation context' do
    subject(:avengers) { Team.new(team: 'Avengers') }

    it 'uses the name as its string representation' do
      expect(avengers.to_s).to eq 'avengers'.path_to_name
    end
  end

  context 'in equality context' do
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

  context 'with a typical team (Avengers)' do
    subject(:avengers) { Team.new(team: 'Avengers') }
    ant_man_folder = File.join(%W[#{Settings.root} avengers hank-pym])
    beast_folder = File.join(%W[#{Settings.root} avengers hank-mccoy])
    
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

    it 'lists its team members' do
      ant_man = Employee.find('hank-pym')
      beast = Employee.find('hank-mccoy')

      expect(avengers.members).to contain_exactly(beast, ant_man)
    end

    it 'lists its team members by folder' do
      expect(avengers.members_by_folder).to contain_exactly(ant_man_folder, beast_folder)
    end
  end

  context 'with a team name with a space (Justice League)' do
    subject(:justice_league) { Team.new(team: 'Justice League') }
    batman_folder = File.join(%W[#{Settings.root} justice-league bruce-wayne])
    superman_folder = File.join(%W[#{Settings.root} justice-league clark-kent])

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
      raise IOError, 'No Batman folder' unless Dir.exist? batman_folder
      raise IOError, 'No Superman folder' unless Dir.exist? superman_folder
      expect(justice_league.members_by_folder).to contain_exactly(batman_folder, superman_folder)
    end
  end

  context 'in finding context' do
    it 'does not find a non-existant team' do
      expect(Team.find('xyzzy')).to be_nil
    end
  end
end
