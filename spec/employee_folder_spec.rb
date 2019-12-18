# frozen_string_literal: true

require './lib/employee'
require './lib/employee_folder'
require_relative 'settings_helper'

RSpec.describe EmployeeFolder do
  shared_examples 'ensure exists' do
    it 'ensure_exists ensures the folder exists' do
      FileUtils.rm_r subject.path if Dir.exist? subject.path
      expect(Dir).not_to exist(subject.path)
      
      subject.ensure_exists
      expect(Dir).to exist(subject.path)
    end
  end
 
  context 'with normal characters' do
    subject(:normal_folder) do
      john = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      EmployeeFolder.new(john)
    end
    
    normal_path = File.join %W[#{Settings.root} normal]

    before do
      FileUtils.mkdir_p normal_path
    end

    after do
      FileUtils.rm_r normal_path
    end

    it { is_expected.to have_attributes(folder_name: 'john-smith', path: File.join(normal_path, 'john-smith')) }

    it_has_behavior 'ensure exists'

    it 'returns the path when cast as a string' do
      expect(normal_folder.to_s).to eq normal_folder.path
    end
  end

  context 'with accented characters' do
    subject(:accented_folder) do
      ezel = Employee.new(team: 'ĀčĊÉñŤÈÐ', first: 'Ezel', last: 'Çeçek')
      EmployeeFolder.new(ezel)
    end

    accented_path =  File.join(%W[#{Settings.root} āčċéñťèð])

    before do
      FileUtils.mkdir_p accented_path
    end

    after do
      FileUtils.rm_r accented_path
    end

    it { is_expected.to have_attributes(folder_name: 'ezel-çeçek', path: File.join(accented_path, 'ezel-çeçek')) }

    it_has_behavior 'ensure exists'
  end

  context 'with nonalnum characters' do
    subject(:nonalnum_folder) do
      bad = Employee.new(team: 'bad', first: 'J%hn', last: 'Sm][th')
      EmployeeFolder.new bad
    end
    
    nonalnum_path = File.join %W[#{Settings.root} bad]

    before do
      FileUtils.mkdir_p nonalnum_path
    end

    after do
      FileUtils.rm_r nonalnum_path
    end

    it { is_expected.to have_attributes(folder_name: 'jhn-smth', path: File.join(nonalnum_path, 'jhn-smth')) }

    it_has_behavior 'ensure exists'
  end
end
