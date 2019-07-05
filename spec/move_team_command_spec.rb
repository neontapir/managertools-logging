# frozen_string_literal: true

require 'spec_helper'
require './lib/employee.rb'
require './lib/move_team_command.rb'
require './lib/new_hire_command.rb'

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
      expect { subject.command %w[Princess justice-league] }.to output(/Princess Koriandr/).to_stdout

      expect(Dir.exist? 'data/justice-league/princess-koriandr').to be_truthy
      expect(Dir.exist? 'data/teen-titans/princess-koriandr').to be_falsey
    end

    it 'writes a log entry' do
      expect { subject.command %w[Princess justice-league] }.to output(/Princess Koriandr/).to_stdout
      
      starfire = Employee.find('Princess')
      expect(starfire.file.path).to eq 'data/justice-league/princess-koriandr/log.adoc'
      expect(File.read(starfire.file.path)).to include 'Moving Princess Koriandr to team Justice League'
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
      expect { subject.command %w[Princess Teen\ Titans] }.to output(/is already in the expected folder/).to_stdout

      expect(Dir.exist? 'data/teen-titans/princess-koriandr').to be_truthy
    end
  end
end