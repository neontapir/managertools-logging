# frozen_string_literal: true

require './lib/employee'
require './lib/employee_folder'
require_relative 'settings_helper'

RSpec.describe EmployeeFolder do
  context 'with normal characters' do
    subject(:normal_folder) do
      john = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      EmployeeFolder.new(john)
    end
    
    normal_path = File.join(%W[#{Settings.root} normal])

    before :context do
      FileUtils.mkdir_p normal_path unless Dir.exist? normal_path
    end

    after :context do
      FileUtils.rm_r normal_path
    end

    it 'creates folder with normal characters' do
      expected_path = File.join(normal_path, 'john-smith')
      expect(normal_folder.path).to eq expected_path

      normal_folder.ensure_exists
      expect(Dir).to exist(expected_path)
    end

    it 'returns the path when cast as a string' do
      expect(normal_folder.to_s).to eq subject.path
    end
  end

  context 'with accented characters' do
    subject(:accented_folder) do
      ezel = Employee.new(team: 'ĀčĊÉñŤÈÐ', first: 'Ezel', last: 'Çeçek')
      EmployeeFolder.new(ezel)
    end

    accented_path =  File.join(%W[#{Settings.root} āčċéñťèð])

    before :context do
      FileUtils.mkdir_p accented_path unless Dir.exist? accented_path
    end

    after :context do
      FileUtils.rm_r accented_path
    end

    it 'creates folder with accented characters' do
      expected_path = File.join(accented_path, 'ezel-çeçek')
      expect(accented_folder.path).to eq expected_path

      accented_folder.ensure_exists
      expect(Dir).to exist(expected_path)
    end
  end

  context 'with nonalnum characters' do
    nonalnum_path = File.join(%W[#{Settings.root} bad])
    sanitized_name = 'jhn-smth'

    before :context do
      FileUtils.mkdir_p nonalnum_path
    end

    after :context do
      FileUtils.rm_r nonalnum_path
    end

    subject(:nonalnum_folder) do
      bad = Employee.new(team: 'bad', first: 'J%hn', last: 'Sm][th')
      EmployeeFolder.new bad
    end

    it 'ensures the folder name does not contain non-alphanumeric characters' do  
      expected_path = File.join(nonalnum_path, sanitized_name)
      FileUtils.rm_r expected_path if Dir.exist? expected_path
      expect(Dir).not_to exist(expected_path)
      nonalnum_folder.ensure_exists
      expect(Dir).to exist(expected_path)
    end

    it 'strips non-alphanumeric characters from the name' do
      expect(nonalnum_folder.folder_name).to eq sanitized_name
    end
  end
end
