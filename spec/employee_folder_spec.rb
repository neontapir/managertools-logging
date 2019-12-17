# frozen_string_literal: true

require './lib/employee'
require './lib/employee_folder'
require_relative 'settings_helper'

RSpec.describe EmployeeFolder do
  context 'with normal characters' do
    normal_folder =  File.join(%W[#{Settings.root} normal])

    before :all do
      FileUtils.mkdir_p normal_folder unless Dir.exist? normal_folder
    end

    after :all do
      FileUtils.rm_r normal_folder
    end

    subject do
      john = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      EmployeeFolder.new(john)
    end

    it 'creates folder with normal characters' do
      expected_path = File.join(normal_folder, 'john-smith')
      expect(subject.path).to eq expected_path

      subject.ensure_exists
      expect(Dir.exist?(expected_path))
    end

    it 'returns the path when cast as a string' do
      expect(subject.to_s).to eq subject.path
    end
  end

  context 'with accented characters' do
    accented_folder =  File.join(%W[#{Settings.root} āčċéñťèð])

    before :all do
      FileUtils.mkdir_p accented_folder unless Dir.exist? accented_folder
    end

    after :all do
      FileUtils.rm_r accented_folder
    end

    subject do
      ezel = Employee.new(team: 'ĀčĊÉñŤÈÐ', first: 'Ezel', last: 'Çeçek')
      EmployeeFolder.new(ezel)
    end

    it 'creates folder with accented characters' do
      expected_path = File.join(accented_folder, 'ezel-çeçek')
      expect(subject.path).to eq expected_path

      subject.ensure_exists
      expect(Dir.exist?(expected_path))
    end
  end

  context 'with nonalnum characters' do
    nonalnum_path = File.join(%W[#{Settings.root} bad])
    sanitized_name = 'jhn-smth'

    before :all do
      FileUtils.mkdir_p nonalnum_path
    end

    after :all do
      FileUtils.rm_r nonalnum_path
    end

    subject do
      bad = Employee.new(team: 'bad', first: 'J%hn', last: 'Sm][th')
      EmployeeFolder.new bad
    end

    it 'ensures the folder name does not contain non-alphanumeric characters' do  
      expected_path = File.join(nonalnum_path, sanitized_name)
      FileUtils.rm_r expected_path if Dir.exist? expected_path
      expect(Dir.exist? expected_path).to be_falsey
      subject.ensure_exists
      expect(Dir.exist? expected_path).to be_truthy
    end

    it 'strips non-alphanumeric characters from the name' do
      expect(subject.folder_name).to eq sanitized_name
    end
  end
end
