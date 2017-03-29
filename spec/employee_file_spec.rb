require './lib/employee_file.rb'
require './lib/employee_folder.rb'

describe EmployeeFile do
  before(:all) do
    FileUtils.mkdir_p('data/normal')
  end

  after(:all) do
    FileUtils.rm_r('data/normal')
  end

  it 'should join paths correctly' do
    employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
    folder = EmployeeFolder.new employee
    expect(EmployeeFile.new(folder ,'file').path).to eq('data/normal/john-smith/file')
  end
end
