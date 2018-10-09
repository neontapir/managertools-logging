# frozen_string_literal: true

require './lib/employee_file.rb'
require './lib/employee_folder.rb'

describe EmployeeFile do
  before(:all) do
    FileUtils.mkdir_p('data/normal')
  end

  after(:all) do
    FileUtils.rm_r('data/normal')
  end

  it 'raises if no folder given' do
    expect { EmployeeFile.new(nil, anything) }.to raise_error ArgumentError, 'Folder cannot be empty'
  end

  it 'raises if no file given' do
    employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
    folder = EmployeeFolder.new employee
    expect { EmployeeFile.new(folder, nil) }.to raise_error ArgumentError, 'Filename cannot be empty'
  end

  it 'joins paths correctly' do
    employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
    folder = EmployeeFolder.new employee
    expect(EmployeeFile.new(folder, 'file').path).to eq('data/normal/john-smith/file')
  end

  it 'joins paths correctly for hyphenated names' do
    employee = Employee.new(team: 'normal', first: 'John', last: 'Smith-Jones')
    folder = EmployeeFolder.new employee
    expect(EmployeeFile.new(folder, 'file').path).to eq('data/normal/john-smith-jones/file')
  end
end
