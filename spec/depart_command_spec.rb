# frozen_string_literal: true

require './lib/settings'
require './lib/commands/depart_command'
require './lib/commands/new_hire_command'
require_relative 'spec_helper'

RSpec.describe DepartCommand do
  context 'moving a departing team member' do
    depart_root = File.join(%W[#{Settings.root} #{Settings.departed_root}])
    depart_folder = File.join(%W[#{Settings.root} teen-titans])

    before(:each) do
      FileUtils.rm_r depart_root if Dir.exist? depart_root
      FileUtils.mkdir_p depart_folder

      # use new hire command to generate expected files
      expect { NewHireCommand.new.command %w[Teen\ Titans Princess Koriand'r] }.to output(/princess-koriandr/).to_stdout
    end

    after(:each) do
      FileUtils.rm_r depart_folder
    end

    subject { DepartCommand.new }

    it 'relocates their files' do
      expect(Dir.exist? depart_root).to be_falsey

      expect { subject.command 'Princess' }.to output(/Princess Koriandr/).to_stdout

      expect(Dir.exist? File.join(%W[#{depart_root} princess-koriandr])).to be_truthy
      expect(Dir.exist? File.join(%W[#{depart_folder} princess-koriandr])).to be_falsey
    end
  end
end
