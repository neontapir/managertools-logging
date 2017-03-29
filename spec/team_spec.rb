require './lib/team.rb'

describe Team do
  context 'in initializer context' do
    it 'should raise if params hash does not contain a team entry' do
      expect{Team.new({})}.to raise_error KeyError
    end
  end

  context 'in equality context' do
    before(:all) do
      @avengers = Team.new(team: 'Avengers')
      @justice_league = Team.new(team: 'JusticeLeague')
    end

    it 'should find the same team equal to itself' do
      expect(@avengers.eql?(@avengers)).to be true
      expect(@justice_league.eql?(@justice_league)).to be true
    end

    it 'should not find different teams equal to each other' do
      expect(@avengers.eql?(@justice_league)).to be false
      expect(@justice_league.eql?(@avengers)).to be false
    end

    it 'should get the same results with the equals operator' do
      expect(@avengers == @avengers).to be true
      expect(@avengers == @justice_league).to be false
    end

    it 'should find teams with different casing in names the same' do
      avengers_miniscule = Team.new(team: 'avengers')
      expect(@avengers.eql?(avengers_miniscule)).to be true
    end

    it 'should not a team equal to a non-team' do
      expect(@avengers.eql?('Avengers')).to be false
    end
  end

  it 'should not find a non-existant team' do
    expect(Team.find('xyzzy')).to be nil
  end

  it 'should create the name correctly' do
    expect(Team.to_name('avengers')).to eq('Avengers')
    expect(Team.to_name('justice-league')).to eq('Justice League')
    expect(Team.to_name('Justice League')).to eq('Justice League')
  end

  it 'should use the name as its string representation' do
    avengers = Team.new(team: 'Avengers')
    expect(avengers.to_s).to eq(Team.to_name('avengers'))
  end

  it 'should create the path string correctly' do
    expect(Team.to_path_string('avengers')).to eq('avengers')
    expect(Team.to_path_string('justice-league')).to eq('justice-league')
    expect(Team.to_path_string('Justice League')).to eq('justice-league')
  end

  context 'in Avengers context' do
    before(:all) do
      Dir.mkdir('data') unless Dir.exist? 'data'
      Dir.mkdir('data/avengers')
      Dir.mkdir('data/avengers/hank-pym')   # Ant Man
      Dir.mkdir('data/avengers/hank-mccoy') # Beast
      @avengers = Team.new(team: 'Avengers')
    end

    after(:all) do
      FileUtils.remove_dir('data/avengers')
    end

    it 'should find the team' do
      team = Team.find('avengers')
      expect(team).to eq(@avengers)
    end

    it 'should use the name as the string representation' do
      avengers = Team.new(team: 'Avengers')
      expect(avengers.to_s).to eq(Team.to_name('avengers'))
    end

    it 'should return list of team members' do
      beast = Employee.find('hank-mccoy')
      ant_man = Employee.find('hank-pym')

      expect(@avengers.members).to contain_exactly(beast, ant_man)
    end

    it 'should return list of team members by folder' do
      expect(@avengers.members_by_folder).to contain_exactly(
        'data/avengers/hank-mccoy',
        'data/avengers/hank-pym'
      )
    end
  end

  context 'in Justice League context' do
    before(:all) do
      FileUtils.mkdir_p('data/justice-league/bruce-wayne') # Batman
      FileUtils.mkdir_p('data/justice-league/clark-kent') # Superman
      @justice_league = Team.new(team: 'Justice League')
    end

    after(:all) do
      FileUtils.remove_dir('data/justice-league')
    end

    it 'should display the team as capitalized' do
      expect(@justice_league.to_s).to eq('Justice League')
    end

    it 'should return list of team members by folder' do
      raise IOError, 'No Batman folder' unless Dir.exist? 'data/justice-league/bruce-wayne'
      raise IOError, 'No Superman folder' unless Dir.exist? 'data/justice-league/clark-kent'
      expect(@justice_league.members_by_folder).to contain_exactly(
        'data/justice-league/bruce-wayne',
        'data/justice-league/clark-kent'
      )
    end
  end
end
