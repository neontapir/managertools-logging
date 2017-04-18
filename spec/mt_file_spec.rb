require './lib/mt_file.rb'

describe MtFile do
  context 'with a naive instance' do
    subject { (Class.new { include MtFile }).new }

    it 'raises an error if path isn\'t defined' do
      expect { subject.path }.to raise_error(NotImplementedError, 'A MtFile must define its #path')
    end
  end

  context 'with a typical instance' do
    # Helper class for testing MtFile
    MtFileClass = Class.new do
      include MtFile
      def path
        'data/mtfile/foo'
      end
    end

    before(:each) do
      FileUtils.mkdir_p('data/mtfile')
    end

    after(:each) do
      FileUtils.rm_r('data/mtfile')
    end

    subject { MtFileClass.new }

    def foo_exists
      File.exist?('data/mtfile/foo')
    end

    it 'knows the file path' do
      expect(subject.path).to eq('data/mtfile/foo')
    end

    it 'is represented as a string by its path' do
      expect(subject.to_s).to eq(subject.path)
    end

    context 'when ensuring existance' do
      it 'creates a file if none exists' do
        expect(foo_exists).to be_falsey
        subject.ensure_exists
        expect(foo_exists).to be_truthy
      end

      it 'does nothing if file already exists' do
        expect(foo_exists).to be_falsey
        subject.ensure_exists
        expect(foo_exists).to be_truthy
        subject.ensure_exists
        expect(foo_exists).to be_truthy
      end
    end
  end
end