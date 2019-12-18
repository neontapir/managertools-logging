# frozen_string_literal: true

require './lib/employee'
require './lib/settings'
require './lib/commands/move_team_command'
require './lib/commands/new_hire_command'
require_relative 'spec_helper'

RSpec.describe MoveTeamCommand do
  context 'moving a team member' do
    justice_league_folder = File.join %W[#{Settings.root} justice-league]
    teen_titans_folder = File.join %W[#{Settings.root} teen-titans]
    starfire_id = 'princess-koriandr'

    before do
      [justice_league_folder, teen_titans_folder].each do |folder|
        FileUtils.mkdir_p folder
      end

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Teen\ Titans Princess Koriand'r] }.to output(/#{starfire_id}/).to_stdout
    end

    after do
      [justice_league_folder, teen_titans_folder].each do |folder|
        FileUtils.rm_r folder
      end
    end

    

    it 'relocates their files' do
      expect { subject.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout

      expect(Dir).to exist File.join(justice_league_folder, starfire_id)
      expect(Dir).not_to exist File.join(teen_titans_folder, starfire_id)
    end

    it 'writes a log entry' do
      expect { subject.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout

      starfire = Employee.find('Princess')
      starfire_log = starfire.file.path
      expect(starfire_log).to eq File.join(justice_league_folder, starfire_id, 'log.adoc')
      expect(File.read(starfire_log)).to include 'Moving Princess Koriandr to team Justice League'
    end

    it 'updates the image folder in the overview file' do
      expect { subject.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout
      starfire = Employee.find('Princess')
      starfire_folder = starfire.file.folder
      starfire_overview = File.join starfire_folder, Settings.overview_filename
      overview_contents = File.read(starfire_overview)
      expect(overview_contents).to include File.join(justice_league_folder, starfire_id)
      expect(overview_contents).not_to include File.join(teen_titans_folder, starfire_id)
    end

    it 'updates the team line in the overview file' do
      expect { subject.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout
      starfire = Employee.find('Princess')
      starfire_folder = starfire.file.folder
      starfire_overview = File.join starfire_folder, Settings.overview_filename
      overview_contents = File.read(starfire_overview)
      expect(overview_contents).to include 'Team: Teen Titans, Justice League'
    end
  end

  context 'moving multiple team members' do
    justice_league_folder = File.join %W[#{Settings.root} justice-league]
    teen_titans_folder = File.join %W[#{Settings.root} teen-titans]

    before do
      [justice_league_folder, teen_titans_folder].each do |folder|
        FileUtils.mkdir_p folder
      end

      # use new hire command to generate expected files
      new_hire = NewHireCommand.new
      expect { new_hire.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
      expect { new_hire.command %w[Teen\ Titans Dick Grayson] }.to output(/dick-grayson/).to_stdout
    end

    after do
      [justice_league_folder, teen_titans_folder].each do |folder|
        FileUtils.rm_r folder
      end
    end

    it 'relocates all their files' do
      expect{ MoveTeamCommand.new.command %w[justice-league Princess Grayson] }.to output.to_stdout

      %w[princess-koriandr dick-grayson].each do |member|
        expect(Dir).to exist File.join(justice_league_folder, "#{member}")
        expect(Dir).not_to exist File.join(teen_titans_folder, "#{member}")
      end
    end
  end

  context 'refuses to move a team member to the same folder' do
    teen_titans_folder = File.join %W[#{Settings.root} teen-titans]
    starfire = 'princess-koriandr'

    before do
      FileUtils.mkdir_p teen_titans_folder

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
    end

    after do
      FileUtils.rm_r teen_titans_folder
    end

    

    it 'prints a message' do
      expect { subject.command %w[Teen\ Titans Princess] }.to output(/is already in the expected folder/).to_stderr

      expect(Dir).to exist File.join(teen_titans_folder, starfire)
    end
  end
end