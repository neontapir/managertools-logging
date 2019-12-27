# frozen_string_literal: true

require 'ostruct'
require './lib/employee'
require './lib/commands/new_hire_command'
require './lib/settings'

RSpec.describe NewHireCommand do
  context 'existing team member (Beast Boy)' do
    teen_titans_folder = File.join %W[#{Settings.root} teen-titans]
    beast_boy_folder = File.join teen_titans_folder, 'garfield-logan'

    before :context do
      FileUtils.mkdir_p teen_titans_folder
    end

    after :context do
      FileUtils.rm_r teen_titans_folder
    end

    it 'creates a new team member' do
      expect(File).not_to exist File.join(beast_boy_folder, Settings.log_filename)
      expect(File).not_to exist File.join(beast_boy_folder, Settings.overview_filename)

      expect { subject.command(%w[Teen\ Titans Garfield Logan]) }.to output(/garfield-logan/).to_stdout

      beast_boy = Employee.find('Gar')
      expect(beast_boy).not_to be_nil

      expect(beast_boy.file.path).to eq File.join(beast_boy_folder, Settings.log_filename)
      expect(File).to exist File.join(beast_boy_folder, Settings.log_filename)
      expect(File).to exist File.join(beast_boy_folder, Settings.overview_filename)
      expect(File.read(beast_boy.file.path)).to include 'File generated by new-hire command'
    end
  end

  context 'force overwrites team member (Robin)' do
    teen_titans_folder = File.join %W[#{Settings.root} teen-titans]

    before :context do
      FileUtils.mkdir_p teen_titans_folder
    end

    after :context do
      FileUtils.rm_r teen_titans_folder
    end

    let(:robin) { Employee.find('Grayson') }
    let(:robin_folder) { File.join(teen_titans_folder, 'dick-grayson') }

    def robin_log_contents
      File.read(robin.file.path)
    end

    def setup_new_hire_with_o3_entry
      expect { subject.command(%w[Teen\ Titans Dick Grayson]) }.to output(/dick-grayson/).to_stdout
      expect(robin).not_to be_nil

      # create a diary entry to differentiate log from a newly created file
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        RecordDiaryEntryCommand.new.command :one_on_one, ['grayson']
      end

      expect(robin.file.path).to eq File.join(robin_folder, Settings.log_filename)
      expect(File).to exist File.join(robin_folder, Settings.log_filename)
      expect(File).to exist File.join(robin_folder, Settings.overview_filename)
      expect(robin_log_contents).to include 'Met about goals'
    end

    it 'will not recreate an existing team member unless force' do
      setup_new_hire_with_o3_entry
      expect(robin_log_contents).to include 'Met about goals'
      expect { subject.command(%w[Teen\ Titans Dick Grayson]) }.to output(/#{Settings.log_filename}... exists/).to_stdout
      expect(robin_log_contents).to include 'Met about goals'
    end

    it 'forces recreates an existing team member' do
      setup_new_hire_with_o3_entry
      expect(robin_log_contents).to include 'Met about goals'
      expect { subject.command(%w[Teen\ Titans Dick Grayson], OpenStruct.new(force: true)) }.to output(/#{Settings.log_filename}... created/).to_stdout
      expect(robin_log_contents).not_to include 'Met about goals'
    end
  end
end
