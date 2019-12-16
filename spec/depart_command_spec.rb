# frozen_string_literal: true

require './lib/settings'
require './lib/commands/depart_command'
require './lib/commands/new_hire_command'
require_relative 'spec_helper'

RSpec.describe MoveTeamCommand do

  context 'moving a departing team member' do
    before(:each) do
      FileUtils.mkdir_p 'data/teen-titans'

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
    end

    after(:each) do
      FileUtils.rm_r 'data/teen-titans'
    end

    subject { DepartCommand.new }

    it 'relocates their files' do
      expect { subject.command %w[Princess] }.to output(/Princess Koriandr/).to_stdout

      expect(Dir.exist? "data/#{Settings.departed_root}/princess-koriandr").to be_truthy
      expect(Dir.exist? 'data/teen-titans/princess-koriandr').to be_falsey
    end
  end
end
