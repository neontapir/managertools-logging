# frozen_string_literal: true

require './lib/mt_file'

RSpec.describe MtFile do
  context 'when path is not defined' do
    subject { (Class.new { include MtFile }).new }

    it 'raises an error' do
      expect { subject.path }.to raise_error(NotImplementedError, 'A MtFile must define its #path')
    end
  end

  context 'with a typical instance' do
    subject(:implementer) do
      (Class.new do
        include MtFile

        def path
          File.join(%W[#{Settings.root} mtfile foo])
        end
      end).new
    end

    mtfileclass_folder = File.join %W[#{Settings.root} mtfile]

    before do
      FileUtils.mkdir_p mtfileclass_folder
    end

    after do
      FileUtils.rm_r mtfileclass_folder
    end

    def foo_exists
      File.exist?(implementer.path)
    end

    def backup_exists
      File.exist?(implementer.backup)
    end

    it 'is represented as a string by its path' do
      expect(implementer.to_s).to eq implementer.path
    end

    context 'when ensuring existance' do
      it 'creates a file if none exists' do
        expect(foo_exists).to be_falsey
        implementer.ensure_exists
        expect(foo_exists).to be_truthy
      end

      it 'does nothing if file already exists' do
        expect(foo_exists).to be_falsey
        implementer.ensure_exists
        expect(foo_exists).to be_truthy
        implementer.ensure_exists
        expect(foo_exists).to be_truthy
      end
    end

    context 'when making a backup' do
      it 'creates a backup file if none exists' do
        expect(foo_exists).to be_falsey
        expect(backup_exists).to be_falsey
        implementer.make_backup
        expect(foo_exists).to be_truthy
        expect(backup_exists).to be_truthy
      end

      it 'removes a backup file' do
        implementer.make_backup
        expect(foo_exists).to be_truthy
        expect(backup_exists).to be_truthy
        implementer.remove_backup
        expect(foo_exists).to be_truthy
        expect(backup_exists).to be_falsey
      end
    end
  end
end
