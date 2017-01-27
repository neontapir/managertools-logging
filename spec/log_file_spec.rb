require "./lib/log_file.rb"

describe LogFile do
  context "in Iron Man context" do
    before(:all) do
      Dir.mkdir("data") unless Dir.exist? "data"
      Dir.mkdir("data/avengers")
      Dir.mkdir("data/avengers/tony-stark")
      tony = Employee.new({team: "Avengers", first: "Tony", last: "Stark"})
      folder = EmployeeFolder.new tony
      @log = LogFile.new folder
    end

    after(:all) do
      File.delete("data/avengers/tony-stark/log.adoc")
      Dir.rmdir("data/avengers/tony-stark")
      Dir.rmdir("data/avengers")
    end

    it "should know its path" do
      expect(@log.path).to eq("data/avengers/tony-stark/log.adoc")
    end

    it "should append an entry" do
      @log.append "foo"
      expect(File.readlines(@log.path).grep(/foo/).size).to be > 0
      expect(File.readlines(@log.path).grep(/bar/).size).not_to be > 0
    end
  end
end
