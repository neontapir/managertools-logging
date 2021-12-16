# frozen_string_literal: true

require 'ostruct'
require './lib/employee'
require './lib/commands/new_hire_command'
require './lib/settings'

RSpec.describe NewHireCommand do
  subject(:new_hire) { NewHireCommand.new }

  def log_contents(employee)
    File.read(employee.file.path)
  end

  def expect_files_created(employee, expected_folder, *phrases)
    expect(employee.file.path).to eq File.join(expected_folder, Settings.log_filename)
    expect(File).to exist File.join(expected_folder, Settings.log_filename)
    expect(File).to exist File.join(expected_folder, Settings.overview_filename)
    contents = log_contents(employee)
    phrases << 'File generated by new-hire command'
    phrases.each do |phrase|
      expect(contents).to include phrase
    end
  end

  context 'when hiring' do
    teen_titans_folder = File.join %W[#{Settings.root} teen-titans]

    before do
      FileUtils.mkdir_p teen_titans_folder
    end

    after do
      FileUtils.rm_r teen_titans_folder
    end

    context 'a new team member (Kid Flash)' do
      kid_flash_folder = File.join %W[#{Settings.root} teen-titans wally-west]

      before :context do
        expect(File).not_to exist File.join(kid_flash_folder, Settings.log_filename)
        expect(File).not_to exist File.join(kid_flash_folder, Settings.overview_filename)
      end

      it 'creates a new team member' do
        expect { new_hire.command(%w[Teen\ Titans Wally West]) }.to output(/wally-west/).to_stdout

        kid_flash = Employee.find('Wal')
        expect(kid_flash).not_to be_nil

        expect_files_created(kid_flash, kid_flash_folder)
      end
    end

    context 'a new team member with data (Beast Boy)' do
      beast_boy_folder = File.join %W[#{Settings.root} teen-titans garfield-logan]

      before :context do
        expect(File).not_to exist File.join(beast_boy_folder, Settings.log_filename)
        expect(File).not_to exist File.join(beast_boy_folder, Settings.overview_filename)
      end

      # these options get passed to the command by the ManagerTools module
      it 'creates a new team member with given data' do
        tomorrow = (Date.today + 1).to_datetime
        expect {
          new_hire.command(%w[Teen\ Titans Garfield Logan], OpenStruct.new(
            biography: 'changed into a West African green monkey to battle Sakutia',
            grade_level: 'newcomer',
            start_date: tomorrow.to_s,
          ))
        }.to output(/garfield-logan/).to_stdout

        beast_boy = Employee.find('Gar')
        expect(beast_boy).not_to be_nil

        expect_files_created(beast_boy, beast_boy_folder,
                             'changed into a West African green monkey to battle Sakutia',
                             "Start date:: #{tomorrow}",
                             'Grade level:: newcomer')
      end
    end

    context 'with force overwrite of an existing member (Robin)' do
      let(:robin) { Employee.find('Grayson') }

      def robin_folder
        File.join %W[#{Settings.root} teen-titans dick-grayson]
      end

      # add content to the file so we can distinguish it from a newly created log file
      def setup_new_hire_with_o3_entry
        expect { new_hire.command(%w[Teen\ Titans Dick Grayson]) }.to output(/dick-grayson/).to_stdout
        expect(robin).not_to be_nil

        # create a diary entry to differentiate log from a newly created file
        Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
          RecordDiaryEntryCommand.new.command :one_on_one, ['grayson']
        end

        expect_files_created(robin, robin_folder, 'Met about goals')
      end

      before :context do
        expect(File).not_to exist File.join(robin_folder, Settings.log_filename)
        expect(File).not_to exist File.join(robin_folder, Settings.overview_filename)
      end

      it 'will not recreate an existing team member unless force' do
        setup_new_hire_with_o3_entry
        expect { new_hire.command(%w[Teen\ Titans Dick Grayson]) }.to output(/#{Settings.log_filename}... exists/).to_stdout
        expect(log_contents(robin)).to include 'Met about goals'
      end

      it 'forces recreates an existing team member' do
        setup_new_hire_with_o3_entry
        expect { new_hire.command(%w[Teen\ Titans Dick Grayson], OpenStruct.new(force: true)) }.to output(/#{Settings.log_filename}... created/).to_stdout
        expect(log_contents(robin)).not_to include 'Met about goals'
      end
    end
  end
end
