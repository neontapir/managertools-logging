require './lib/log_file.rb'

describe LogFile, :order => :defined do
  context 'in Iron Man context' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      folder = EmployeeFolder.new tony
      @log = LogFile.new folder
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    it 'should know its path' do
      expect(@log.path).to eq('data/avengers/tony-stark/log.adoc')
    end

    it 'should create a new file if none exists' do
      @log.append 'foobar'
      expect(File.readlines(@log.path)).to eq ["\n", "foobar\n"]
    end

    it 'should append an entry' do
      @log.append 'baz'
      expect(File.readlines(@log.path)).to eq ["\n", "foobar\n", "\n", "baz\n"]
    end

    it 'should not add an extra leading carriage return if one provided' do
      @log.append "\nqux"
      expect(File.readlines(@log.path)).to eq ["\n", "foobar\n", "\n", "baz\n", "\n", "qux\n"]
    end
  end
end
