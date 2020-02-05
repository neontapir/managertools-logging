# frozen_string_literal: true

require './lib/entity_file'
require './lib/employee_folder'

RSpec.describe EntityFile do
  context 'abnormal construction' do
    it 'raises when no folder given' do
      expect { EntityFile.new(nil, anything) }.to raise_error ArgumentError, 'Folder cannot be empty'
    end

    it 'raises when no file given' do
      employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      folder = EmployeeFolder.new employee
      expect { EntityFile.new(folder, nil) }.to raise_error ArgumentError, 'Filename cannot be empty'
    end
  end

  context 'typical usage' do
    normal_folder = File.join %W[#{Settings.root} normal]
    muppets_in_space_folder = File.join %W[#{Settings.root} muppets-in-space]

    before :context do
      [normal_folder, muppets_in_space_folder].each do |folder|
        FileUtils.mkdir_p folder
      end
    end

    after :context do
      [normal_folder, muppets_in_space_folder].each do |folder|
        FileUtils.rm_r folder
      end
    end

    it 'joins paths correctly' do
      employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      folder = EmployeeFolder.new employee
      expect(EntityFile.new(folder, 'file').path).to eq File.join(normal_folder, 'john-smith/file')
    end

    it 'joins paths correctly for hyphenated employee names' do
      employee = Employee.new(team: 'normal', first: 'John', last: 'Smith-Jones')
      folder = EmployeeFolder.new employee
      expect(EntityFile.new(folder, 'file').path).to eq File.join(normal_folder, 'john-smith-jones/file')
    end

    it 'joins paths correctly for hyphenated team names' do
      employee = Employee.new(team: 'Muppets in Space', first: 'John', last: 'Smith-Jones')
      folder = EmployeeFolder.new employee
      expect(EntityFile.new(folder, 'file').path).to eq File.join(muppets_in_space_folder, 'john-smith-jones/file')
    end
  end

  context 'in equality context' do
    equality_folder = File.join %W[#{Settings.root} equality]

    subject { EntityFile.new(equality_folder, 'equal_file') }

    before :context do
      FileUtils.mkdir_p equality_folder
    end

    after :context do
      FileUtils.rm_r equality_folder
    end

    it 'implements equals' do
      is_expected.to eq EntityFile.new(equality_folder, 'equal_file')
    end

    it 'finds a different folder unequal' do
      different_folder = File.join %W[#{Settings.root} inequality]
      is_expected.not_to eq EntityFile.new(different_folder, 'equal_file')
    end

    it 'finds a different file unequal' do
      is_expected.not_to eq EntityFile.new(equality_folder, 'unequal_file')
    end
  end
end
