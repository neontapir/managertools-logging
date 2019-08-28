# frozen_string_literal: true

require './lib/employee'
require './lib/commands/move_team_command'
require './lib/commands/new_hire_command'
require_relative 'spec_helper'

RSpec.describe MoveTeamCommand do
  context 'moving a team member' do
    before(:each) do
      FileUtils.mkdir_p 'data/justice-league'
      FileUtils.mkdir_p 'data/teen-titans'

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
    end

    after(:each) do
      FileUtils.rm_r 'data/justice-league'
      FileUtils.rm_r 'data/teen-titans'
    end

    subject { MoveTeamCommand.new }

    it 'relocates their files' do
      expect { subject.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout

      expect(Dir.exist? 'data/justice-league/princess-koriandr').to be_truthy
      expect(Dir.exist? 'data/teen-titans/princess-koriandr').to be_falsey
    end

    it 'writes a log entry' do
      expect { subject.command %w[justice-league Princess] }.to output(/Princess Koriandr/).to_stdout

      starfire = Employee.find('Princess')
      starfire_path = starfire.file.path
      expect(starfire_path).to eq 'data/justice-league/princess-koriandr/log.adoc'
      expect(File.read(starfire_path)).to include 'Moving Princess Koriandr to team Justice League'
    end
  end

  context 'moving multiple team members' do
    before(:each) do
      FileUtils.mkdir_p 'data/justice-league'
      FileUtils.mkdir_p 'data/teen-titans'

      # use new hire command to generate expected files
      new_hire = NewHireCommand.new
      expect { new_hire.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
      expect { new_hire.command %w[Teen\ Titans Dick Grayson] }.to output(/dick-grayson/).to_stdout
    end

    after(:each) do
      FileUtils.rm_r 'data/justice-league'
      FileUtils.rm_r 'data/teen-titans'
    end

    it 'relocates all their files' do
      expect{ MoveTeamCommand.new.command %w[justice-league Princess Grayson] }.to output.to_stdout
      
      %w[princess-koriandr dick-grayson].each do |member|
        expect(Dir.exist? "data/justice-league/#{member}").to be_truthy
        expect(Dir.exist? "data/teen-titans/#{member}").to be_falsey
      end
    end
  end

  context 'refuses to move a team member to the same folder' do
    before(:each) do
      FileUtils.mkdir_p 'data/teen-titans'

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
    end

    after(:each) do
      FileUtils.rm_r 'data/teen-titans'
    end

    subject { MoveTeamCommand.new }

    it 'prints a message' do
      expect { subject.command %w[Teen\ Titans Princess] }.to output(/is already in the expected folder/).to_stderr

      expect(Dir.exist? 'data/teen-titans/princess-koriandr').to be_truthy
    end
  end
end