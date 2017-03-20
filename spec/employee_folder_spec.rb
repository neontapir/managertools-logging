require './lib/employee.rb'
require './lib/employee_folder.rb'
require_relative 'settings_helper'

include SettingsHelper

describe EmployeeFolder do
  context 'in normal characters context' do
    before(:all) do
      Dir.mkdir('data') unless Dir.exist? 'data'
      create_test_settings_file
      Dir.mkdir('data/normal') unless Dir.exist? 'data/normal'
      employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      @folder = EmployeeFolder.new employee
    end

    after(:all) do
      FileUtils.remove_dir('data/normal')
      remove_test_settings_file
    end

    it 'should create folder with normal characters' do
      expected_path = 'data/normal/john-smith'
      expect(@folder.path).to eq(expected_path)

      @folder.ensure_exists
      expect(Dir.exist?(expected_path))
    end

    it 'should return the path when cast as a string' do
      expect(@folder.to_s).to eq(@folder.path)
    end
  end

  context 'in accented characters context' do
    before(:all) do
      Dir.mkdir('data') unless Dir.exist? 'data'
      Dir.mkdir('data/āčċéñťèð') unless Dir.exist? 'data/āčċéñťèð'
    end

    after(:all) do
      FileUtils.remove_dir('data/āčċéñťèð')
    end

    it 'should create folder with accented characters' do
      employee = Employee.new(team: 'ĀčĊÉñŤÈÐ', first: 'Ezel', last: 'Çeçek')
      folder = EmployeeFolder.new employee
      expected_path = 'data/āčċéñťèð/ezel-çeçek'
      expect(folder.path).to eq(expected_path)

      folder.ensure_exists
      expect(Dir.exist?(expected_path))
    end
  end

  context 'in nonalnum characters context' do
    before(:all) do
      Dir.mkdir('data') unless Dir.exist? 'data'
      Dir.mkdir('data/bad') unless Dir.exist? 'data/bad'

      employee = Employee.new(team: 'bad', first: 'J%hn', last: 'Sm][th')
      @folder = EmployeeFolder.new employee
    end

    after(:all) do
      FileUtils.remove_dir('data/bad')
    end

    it 'should ensure the correct folder exists' do
      Dir.rmdir('data/bad/jhn-smth') if Dir.exist? 'data/bad/jhn-smth'
      expect(Dir.exist?('data/bad/jhn-smth')).to be_falsey
      @folder.ensure_exists
      expect(Dir.exist?('data/bad/jhn-smth')).to be_truthy
    end

    it 'should strip non-alphanumeric characters from the name' do
      expect(@folder.folder_name).to eq('jhn-smth')
    end
  end
end
