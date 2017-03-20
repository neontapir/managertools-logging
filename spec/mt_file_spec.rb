require './lib/mt_file.rb'

describe MtFile do
  # Helper class for testing MtFile
  MtFileClass = Class.new do
    include MtFile
    def path
      'data/mtfile/foo'
    end
  end

  let(:file_instance) { MtFileClass.new }
  let(:naive_instance) { (Class.new { include MtFile }).new }

  it 'raises an error if path isn\'t defined' do
    expect { naive_instance.path }.to raise_error(NotImplementedError, 'A MtFile must define its #path')
  end

  def foo_exists
    File.exist?('data/mtfile/foo')
  end

  context 'when working with MT files' do
    before(:each) do
      Dir.mkdir('data') unless Dir.exist? 'data'
      Dir.mkdir('data/mtfile') unless Dir.exist? 'data/mtfile'
    end

    after(:each) do
      File.delete('data/mtfile/foo') if File.exist? 'data/mtfile/foo'
      Dir.rmdir('data/mtfile') if Dir.exist? 'data/mtfile'
    end

    it 'should be represented as a string by its path' do
      expect(file_instance.to_s).to eq(file_instance.path)
    end

    it 'should contain a path method' do
      expect(file_instance.path).to eq('data/mtfile/foo')
    end

    it 'should create a file' do
      expect(foo_exists).to be_falsey
      file_instance.create
      expect(foo_exists).to be_truthy
    end

    context 'and ensuring file existance' do
      it 'should create a file if none does' do
        expect(foo_exists).to be_falsey
        file_instance.ensure_exists
        expect(foo_exists).to be_truthy
      end

      it 'should do nothing if file already exists' do
        expect(foo_exists).to be_falsey
        file_instance.create
        expect(foo_exists).to be_truthy
        file_instance.ensure_exists
        expect(foo_exists).to be_truthy
      end
    end
  end
end
