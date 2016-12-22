require "./lib/team.rb"

describe Team do
  it "should return a name" do
    avengers = { team: "avengers" }
    team = Team.new avengers
    expect(team.to_s).to eq "Avengers"
  end

  context "in Ant Man and Beast context" do
    before(:all) do
      Dir.mkdir("data") unless Dir.exist? "data"
      Dir.mkdir("data/avengers")
      Dir.mkdir("data/avengers/hank-pym")   # Ant Man
      Dir.mkdir("data/avengers/hank-mccoy") # Beast
    end

    after(:all) do
      Dir.rmdir("data/avengers/hank-mccoy")
      Dir.rmdir("data/avengers/hank-pym")
      Dir.rmdir("data/avengers")
    end

    it "should find the team" do
      avengers = { team: "Avengers" }
      expected = Team.new(avengers)
      team = Team.find("avengers")

      expect(team).to eq(expected)
    end

    it "should return list of team members" do
      avengers = { team: "Avengers" }
      team = Team.new avengers
      beast = Employee.find("hank-mccoy")
      ant_man = Employee.find("hank-pym")

      expect(team.members).to contain_exactly(beast, ant_man)
    end

    it "should return list of team members by folder" do
      avengers = { team: "Avengers" }
      team = Team.new avengers
      expect(team.members_by_folder).to contain_exactly("data/avengers/hank-mccoy",
        "data/avengers/hank-pym")
    end
  end
end
