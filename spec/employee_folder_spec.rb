require "./lib/employee.rb"
require "./lib/employee_folder.rb"

describe EmployeeFolder do
  context "in normal characters context" do
    before(:all) do
      Dir.mkdir("data") unless Dir.exist? "data"
      Dir.mkdir("data/normal")
    end

    after(:all) do
      Dir.rmdir("data/normal/john-smith")
      Dir.rmdir("data/normal")
    end

    it "should create folder with normal characters" do
      employee = Employee.new({team: 'normal', first: 'John', last: 'Smith'})
      folder = EmployeeFolder.new employee
      expected_path = "data/normal/john-smith"
      expect(folder.path).to eq(expected_path)

      folder.ensure_exists
      expect(Dir.exist? expected_path)
    end
  end

  context "in accented characters context" do
    before(:all) do
      Dir.mkdir("data") unless Dir.exist? "data"
      Dir.mkdir("data/āčċéñťèð")
    end

    after(:all) do
      Dir.rmdir("data/āčċéñťèð/ezel-çeçek")
      Dir.rmdir("data/āčċéñťèð")
    end

    it "should create folder with accented characters" do
      employee = Employee.new({team: 'ĀčĊÉñŤÈÐ', first: 'Ezel', last: 'Çeçek'})
      folder = EmployeeFolder.new employee
      expected_path = "data/āčċéñťèð/ezel-çeçek"
      expect(folder.path).to eq(expected_path)

      folder.ensure_exists
      expect(Dir.exist? expected_path)
    end
  end
end
