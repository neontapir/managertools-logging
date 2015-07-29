require "./lib/employee.rb"

describe Employee do
  it "should return a name" do
    cap = { team: "Avengers", first: "Steve", last: "Rogers" }
    captain_america = Employee.new cap
    expect(captain_america.to_s).to eq "Steve Rogers"
  end

  context "in Iron Man context" do
    before(:all) do
      Dir.mkdir("data") unless Dir.exist? "data"
      Dir.mkdir("data/avengers")
      Dir.mkdir("data/avengers/tony-stark")
    end

    after(:all) do
      Dir.rmdir("data/avengers/tony-stark")
      Dir.rmdir("data/avengers")
    end

    it "should parse a folder correctly" do
      dir = Dir.new("data/avengers/tony-stark")
      iron_man = Employee.parse_dir(dir)
      expect(iron_man[:team]).to eq "avengers"
      expect(iron_man[:first]).to eq "Tony"
      expect(iron_man[:last]).to eq "Stark"
    end

    it "should find Iron Man" do
      iron_man = Employee.find("tony")
      expect(iron_man).not_to be_nil
      expect(iron_man.team).to eq "avengers"
      expect(iron_man.first).to eq "Tony"
      expect(iron_man.last).to eq "Stark"
    end

    it "should not find Captain America" do
      employee = Employee.find("steve")
      expect(employee).to be_nil
    end
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

    it "should return first in alphabetical order if multiples match" do
      beast = Employee.find("hank")
      expect(beast).not_to be_nil
      expect(beast.team).to eq "avengers"
      expect(beast.first).to eq "Hank"
      expect(beast.last).to eq "Mccoy"
    end

    it "should find someone if given a unique key" do
      ant_man = Employee.find("hank-p")
      expect(ant_man.team).to eq "avengers"
      expect(ant_man.first).to eq "Hank"
      expect(ant_man.last).to eq "Pym"
    end
  end
end
