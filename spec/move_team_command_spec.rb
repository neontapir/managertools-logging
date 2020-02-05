# frozen_string_literal: true

require './lib/employee'
require './lib/commands/move_team_command'
require './lib/commands/new_hire_command'
require './lib/settings'
require_relative 'spec_helper'

RSpec.describe MoveTeamCommand do
  context 'moving' do
    subject(:move_command) { MoveTeamCommand.new }
    new_hire = NewHireCommand.new

    justice_league_folder = File.join %W[#{Settings.root} justice-league]
    teen_titans_folder = File.join %W[#{Settings.root} teen-titans]

    before do
      [justice_league_folder, teen_titans_folder].each do |folder|
        FileUtils.mkdir_p folder
      end
    end

    after do
      [justice_league_folder, teen_titans_folder].each do |folder|
        FileUtils.rm_r folder
      end
    end

    context 'a team member to another team (Starfire)' do
      starfire_id = 'princess-koriandr'

      before do
        # use new hire command to generate expected files
        expect { new_hire.command %w[Teen\ Titans Princess Koriand'r] }.to output(/#{starfire_id}/).to_stdout
      end

      it 'relocates their files' do
        expect { move_command.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout

        expect(Dir).to exist File.join(justice_league_folder, starfire_id)
        expect(Dir).not_to exist File.join(teen_titans_folder, starfire_id)
      end

      it 'writes a log entry' do
        expect { move_command.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout

        starfire = Employee.find('Princess')
        starfire_log = starfire.file.path
        expect(starfire_log).to eq File.join(justice_league_folder, starfire_id, Settings.log_filename)
        expect(File.read(starfire_log)).to include 'Moving Princess Koriandr to team Justice League'
      end

      it 'updates the image folder in the overview file' do
        expect { move_command.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout
        starfire = Employee.find('Princess')
        starfire_folder = starfire.file.folder
        starfire_overview = File.join starfire_folder, Settings.overview_filename
        overview_contents = File.read(starfire_overview)
        expect(overview_contents).to include File.join(justice_league_folder, starfire_id)
        expect(overview_contents).not_to include File.join(teen_titans_folder, starfire_id)
      end

      it 'updates the team line in the overview file' do
        expect { move_command.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout
        starfire = Employee.find('Princess')
        starfire_folder = starfire.file.folder
        starfire_overview = File.join starfire_folder, Settings.overview_filename
        overview_contents = File.read(starfire_overview)
        expect(overview_contents).to include 'Team: Teen Titans, Justice League'
      end
    end

    context 'a team member to another team with swapped parameters (Red Arrow)' do
      let(:red_arrow) { 'roy-harper' }

      before do
        # use new hire command to generate expected files
        expect { new_hire.command %w[Teen\ Titans Roy Harper] }.to output(/#{red_arrow}/).to_stdout
      end

      it 'relocates their files' do
        expect { move_command.command %w[Harper justice-league] }
          .to output(/no team matching.*swapping/i).to_stderr
          .and output(/moving.*harper/i).to_stdout

        expect(Dir).to exist File.join(justice_league_folder, red_arrow)
        expect(Dir).not_to exist File.join(teen_titans_folder, red_arrow)
      end
    end

    context 'multiple team members at once (Cyborg, Robin)' do
      before do
        # use new hire command to generate expected files
        expect { new_hire.command %w[Teen\ Titans Victor Stone] }.to output(/victor-stone/).to_stdout
        expect { new_hire.command %w[Teen\ Titans Dick Grayson] }.to output(/dick-grayson/).to_stdout
      end

      it 'relocates all their files' do
        expect { move_command.command %w[justice-league Stone Grayson] }.to output.to_stdout

        %w[victor-stone dick-grayson].each do |member|
          expect(Dir).to exist File.join(justice_league_folder, "#{member}")
          expect(Dir).not_to exist File.join(teen_titans_folder, "#{member}")
        end
      end
    end

    context 'a team member to the same folder fails (Raven)' do
      let(:raven) { 'rachel-roth' }

      before do
        # use new hire command to generate expected files
        expect { new_hire.command %w[Teen\ Titans Rachel Roth] }.to output(/#{raven}/).to_stdout
      end

      it 'prints a message' do
        expect { move_command.command %w[Teen\ Titans Rachel] }.to output(/is already in the expected folder/).to_stderr

        expect(Dir).to exist File.join(teen_titans_folder, raven)
      end
    end
  end
end
