# frozen_string_literal: true

require './lib/employee_file'
require './lib/employee_folder'

RSpec.describe EmployeeFile do
  before(:all) do
    FileUtils.mkdir_p 'data/normal'
    FileUtils.mkdir_p 'data/muppets-in-space'
  end

  after(:all) do
    FileUtils.rm_r 'data/normal'
    FileUtils.rm_r 'data/muppets-in-space'
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
    expect(EmployeeFile.new(folder, 'file').path).to eq 'data/normal/john-smith/file'
  end

  it 'joins paths correctly for hyphenated employee names' do
    employee = Employee.new(team: 'normal', first: 'John', last: 'Smith-Jones')
    folder = EmployeeFolder.new employee
    expect(EmployeeFile.new(folder, 'file').path).to eq 'data/normal/john-smith-jones/file'
  end

  it 'joins paths correctly for hyphenated team names' do
    employee = Employee.new(team: 'Muppets in Space', first: 'John', last: 'Smith-Jones')
    folder = EmployeeFolder.new employee
    expect(EmployeeFile.new(folder, 'file').path).to eq 'data/muppets-in-space/john-smith-jones/file'
  end
end
