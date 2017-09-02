require './lib/employee.rb'
require './lib/employee_folder.rb'
require_relative 'settings_helper'

describe EmployeeFolder do
  context 'with normal characters' do
    before(:all) do
      FileUtils.mkdir_p('data/normal') unless Dir.exist? 'data/normal'
    end

    after(:all) do
      FileUtils.rm_r('data/normal')
    end

    subject do
      john = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      EmployeeFolder.new(john)
    end

    it 'creates folder with normal characters' do
      expected_path = 'data/normal/john-smith'
      expect(subject.path).to eq(expected_path)

      subject.ensure_exists
      expect(Dir.exist?(expected_path))
    end

    it 'returns the path when cast as a string' do
      expect(subject.to_s).to eq(subject.path)
    end
  end

  context 'with accented characters' do
    before(:all) do
      FileUtils.mkdir_p('data/āčċéñťèð') unless Dir.exist? 'data/āčċéñťèð'
    end

    after(:all) do
      FileUtils.rm_r('data/āčċéñťèð')
    end

    subject do
      ezel = Employee.new(team: 'ĀčĊÉñŤÈÐ', first: 'Ezel', last: 'Çeçek')
      EmployeeFolder.new(ezel)
    end

    it 'creates folder with accented characters' do
      expected_path = 'data/āčċéñťèð/ezel-çeçek'
      expect(subject.path).to eq(expected_path)

      subject.ensure_exists
      expect(Dir.exist?(expected_path))
    end
  end

  context 'with nonalnum characters' do
    before(:all) do
      FileUtils.mkdir_p('data/bad')
    end

    after(:all) do
      FileUtils.rm_r('data/bad')
    end

    subject do
      bad = Employee.new(team: 'bad', first: 'J%hn', last: 'Sm][th')
      EmployeeFolder.new bad
    end

    it 'ensures the correct folder exists' do
      FileUtils.rm_r('data/bad/jhn-smth') if Dir.exist? 'data/bad/jhn-smth'
      expect(Dir.exist?('data/bad/jhn-smth')).to be_falsey
      subject.ensure_exists
      expect(Dir.exist?('data/bad/jhn-smth')).to be_truthy
    end

    it 'strips non-alphanumeric characters from the name' do
      expect(subject.folder_name).to eq('jhn-smth')
    end
  end
end
