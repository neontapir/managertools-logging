require "./lib/employee.rb"
require "./lib/employee_folder.rb"

describe EmployeeFolder do
  context "in accented characters context" do
    before(:all) do
      Dir.mkdir("data") unless Dir.exist? "data"
      Dir.mkdir("data/āccéñťèð")
    end

    after(:all) do
      Dir.rmdir("data/āccéñťèð/ezel-çeçek")
      Dir.rmdir("data/āccéñťèð")
    end

    it "should create folder with accented characters" do
      employee = Employee.new({team: 'ĀccÉñŤÈÐ', first: 'Ezel', last: 'Çeçek'})
      folder = EmployeeFolder.new employee
      expected_path = "data/āccéñťèð/ezel-çeçek"
      expect(folder.path).to eq(expected_path)

      folder.ensure_exists
      expect(Dir.exist? expected_path)
    end
  end
end
