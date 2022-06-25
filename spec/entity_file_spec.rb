# frozen_string_literal: true

require './lib/entity_file'
require './lib/employee_folder'

RSpec.describe EntityFile do
  context 'with abnormal construction' do
    it 'raises when no folder given' do
      expect { described_class.new(nil, anything) }.to raise_error ArgumentError, 'Folder cannot be empty'
    end

    it 'raises when no file given' do
      employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      folder = EmployeeFolder.new employee
      expect { described_class.new(folder, nil) }.to raise_error ArgumentError, 'Filename cannot be empty'
    end
  end

  context 'with typical usage' do
    normal_folder = File.join(Settings.root, 'normal')
    muppets_in_space_folder = File.join(Settings.root, 'muppets-in-space')

    before do
      [normal_folder, muppets_in_space_folder].each do |folder|
        FileUtils.mkdir_p folder
      end
    end

    after do
      [normal_folder, muppets_in_space_folder].each do |folder|
        FileUtils.rm_r folder
      end
    end

    it 'joins paths correctly' do
      employee = Employee.new(team: 'normal', first: 'John', last: 'Smith')
      folder = EmployeeFolder.new employee
      expect(described_class.new(folder, 'file').path).to eq File.join(normal_folder, 'john-smith/file')
    end

    it 'joins paths correctly for hyphenated employee names' do
      employee = Employee.new(team: 'normal', first: 'John', last: 'Smith-Jones')
      folder = EmployeeFolder.new employee
      expect(described_class.new(folder, 'file').path).to eq File.join(normal_folder, 'john-smith-jones/file')
    end

    it 'joins paths correctly for hyphenated team names' do
      employee = Employee.new(team: 'Muppets in Space', first: 'John', last: 'Smith-Jones')
      folder = EmployeeFolder.new employee
      expect(described_class.new(folder, 'file').path).to eq File.join(muppets_in_space_folder, 'john-smith-jones/file')
    end
  end

  context 'when determining equality' do
    equality_folder = File.join(Settings.root, 'equality')

    subject(:equal_file) { described_class.new(equality_folder, 'equal_file') }

    before do
      FileUtils.mkdir_p equality_folder
    end

    after do
      FileUtils.rm_r equality_folder
    end

    it 'implements equals' do
      expect(equal_file).to eq described_class.new(equality_folder, 'equal_file')
    end

    it 'finds a different folder unequal' do
      different_folder = File.join %W[#{Settings.root} inequality]
      expect(equal_file).not_to eq described_class.new(different_folder, 'equal_file')
    end

    it 'finds a different file unequal' do
      expect(equal_file).not_to eq described_class.new(equality_folder, 'unequal_file')
    end
  end
end
