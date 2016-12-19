require "./lib/employee.rb"
require "./lib/employee_folder.rb"

describe EmployeeFolder do
  context "in accented characters context" do
    before(:all) do
      Dir.mkdir("data") unless Dir.exist? "data"
      Dir.mkdir("data/accented")
    end

    after(:all) do
      Dir.rmdir("data/accented/ezel-çeçek")
      Dir.rmdir("data/accented")
    end

    it "should create folder with accented characters" do
      employee = Employee.new({team: 'accented', first: 'Ezel', last: 'Çeçek'})
      folder = EmployeeFolder.new employee
      expected_path = "data/accented/ezel-çeçek"
      expect(folder.path).to eq(expected_path)

      folder.ensure_exists
      expect(Dir.exist? expected_path)
    end
  end
end
