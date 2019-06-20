# frozen_string_literal: true

require 'spec_helper'
require './lib/employee.rb'
require './lib/move_team_command.rb'
require './lib/new_hire_command.rb'

describe MoveTeamCommand do
  context 'existing team member' do
    before(:all) do
      FileUtils.mkdir_p 'data/justice-league'
      FileUtils.mkdir_p 'data/teen-titans'
    end

    after(:all) do
      FileUtils.rm_r 'data/justice-league'
      FileUtils.rm_r 'data/teen-titans'
    end

    it 'moves an existing team member' do
      # use new hire command to generate expected files
      expect { NewHireCommand.new.command ['Teen Titans', 'Princess', "Koriand'r"] }.to output(/princess-koriandr/).to_stdout
      starfire = Employee.find('Princess')
      expect(starfire.file.path).to eq 'data/teen-titans/princess-koriandr/log.adoc'
      
      expect { MoveTeamCommand.new.command ['Princess', 'justice-league'] }.to output(/Princess Koriandr/).to_stdout

      expect(File.exist? 'data/justice-league/princess-koriandr/log.adoc').to be_truthy
      expect(File.exist? 'data/justice-league/princess-koriandr/overview.adoc').to be_truthy
      expect(File.exist? 'data/teen-titans/princess-koriandr/log.adoc').to be_falsey
      expect(File.exist? 'data/teen-titans/princess-koriandr/overview.adoc').to be_falsey
      
      starfire = Employee.find('Princess')
      expect(starfire.file.path).to eq 'data/justice-league/princess-koriandr/log.adoc'
      expect(File.read(starfire.file.path)).to include 'Moving Princess Koriandr to team Justice League'
    end
  end
end