require './lib/log_file.rb'

describe LogFile, :order => :defined do
  context 'with an employee' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    subject do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      folder = EmployeeFolder.new tony
      LogFile.new folder
    end

    it 'knows the file path' do
      expect(subject.path).to eq('data/avengers/tony-stark/log.adoc')
    end

    it 'creates a new file if none exists' do
      subject.append 'foobar'
      expect(File.readlines(subject.path)).to eq ["\n", "foobar\n"]
    end

    it 'appends an entry' do
      subject.append 'baz'
      expect(File.readlines(subject.path)).to eq ["\n", "foobar\n", "\n", "baz\n"]
    end

    it 'does not add an extra leading carriage return if one provided' do
      subject.append "\nqux"
      expect(File.readlines(subject.path)).to eq ["\n", "foobar\n", "\n", "baz\n", "\n", "qux\n"]
    end
  end
end
