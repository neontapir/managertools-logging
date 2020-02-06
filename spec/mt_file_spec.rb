# frozen_string_literal: true

require 'attr_extras'
require './lib/mt_file'

RSpec.describe MtFile do
  context 'when path is not defined' do
    subject(:implementer) { (Class.new { include MtFile }).new }

    it 'raises an error' do
      expect { implementer.path }.to raise_error AttrExtras::MethodNotImplementedError
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

    it 'is represented as a string by its path' do
      expect(implementer.to_s).to eq implementer.path
    end

    context 'when ensuring existance' do
      before do
        expect(File).not_to exist implementer.path
      end

      it 'creates a file if none exists' do
        implementer.ensure_exists
        expect(File).to exist implementer.path
      end

      it 'does nothing if file already exists' do
        implementer.ensure_exists
        implementer.ensure_exists
        expect(File).to exist implementer.path
      end
    end

    context 'when making a backup' do
      before do
        expect(File).not_to exist implementer.path
        expect(File).not_to exist implementer.backup
      end

      it 'creates a backup file if none exists' do
        implementer.make_backup
        expect(File).to exist implementer.path
        expect(File).to exist implementer.backup
      end

      it 'removes a backup file' do
        implementer.make_backup
        implementer.remove_backup
        expect(File).to exist implementer.path
        expect(File).not_to exist implementer.backup
      end
    end
  end
end
