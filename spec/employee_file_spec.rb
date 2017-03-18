require './lib/employee_file.rb'
require './lib/employee_folder.rb'

describe EmployeeFile do
  before(:all) do
    Dir.mkdir('data') unless Dir.exist? 'data'
    Dir.mkdir('data/normal') unless Dir.exist? 'data/normal'
  end

  after(:all) do
    Dir.rmdir('data/normal/john-smith') if Dir.exist? 'data/normal/john-smith'
    Dir.rmdir('data/normal') if Dir.exist? 'data/normal'
  end

  it 'should join paths correctly' do
    employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
    folder = EmployeeFolder.new employee
    expect(EmployeeFile.new(folder ,'file').path).to eq('data/normal/john-smith/file')
  end
end
