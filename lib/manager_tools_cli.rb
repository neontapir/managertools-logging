# frozen_string_literal: true

require 'highline'
require 'thor'
require_relative 'settings'
Dir["#{__dir__}/*_command.rb"].each { |f| require_relative(f) }

module ManagerTools
  # Defines the command-line interface
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    package_name 'Manager Tools'

    desc 'feedback NAME', "Add a feedback log entry"
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map 'fb' => 'feed'
    map 'feed' => 'feed'
    def feedback(*names)
      record_diary_entry(:feedback, Array(names), options)
    end

    desc 'goal NAME', "Add a goal log entry"
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    def goal(name)
      record_diary_entry(:goal, Array(name), options)
    end

    desc 'interview NAME', "Add an interview log entry"
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    def interview(name)
      record_diary_entry(:interview, Array(name), options)
    end

    desc 'obs NAMES', "Add an observation log entry"
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map 'ob' => 'observation'
    map 'obs' => 'observation'
    def observation(*names)
      record_diary_entry(:observation, Array(names), options)
    end

    desc 'o3 NAME', "Add an 1:1 log entry"
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map '3o' => 'one_on_one'
    map 'o3' => 'one_on_one'
    map 'ooo' => 'one_on_one'
    def one_on_one(name)
      record_diary_entry(:one_on_one, Array(name), options)
    end

    desc 'perf NAME', "Add a performance checkpoint log entry"
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map 'check' => 'performance_checkpoint'
    map 'perf' => 'performance_checkpoint'
    def performance_checkpoint(name)
      record_diary_entry(:performance_checkpoint, Array(name), options)
    end

    desc 'depart NAME', "Move the person's files to the departed team, #{Settings.departed_root}"
    def depart(name)
      execute_subcommand(:depart, Array(name), options)
    end

    desc 'gen', 'Create overview files'
    method_option :force, type: :boolean, default: false, desc: 'Overwrite files if they exist'
    map 'gen' => 'generate_overview_files'
    def generate_overview_files
      execute_subcommand(:generate_overview_files, [], options)
    end

    desc 'latest NAME', "Display the person's latest log entry"
    map 'last' => 'last_entry'
    map 'latest' => 'last_entry'
    def last_entry(name)
      execute_subcommand(:last_entry, Array(name), options)
    end

    desc 'move NAME TEAM', "Move the person's files to the specified team"
    map 'move' => 'move_team'
    def move_team(name, team)
      execute_subcommand(:move_team, [name, team], options)
    end

    desc 'new TEAM FIRST LAST', "Create the person's overview and log files in the given team folder"
    method_option :force, type: :boolean, default: false, desc: 'Overwrite files if they exist'
    map 'create' => 'new_hire'
    map 'new' => 'new_hire'
    def new_hire(team, first, last)
      execute_subcommand(:new_hire, [team, first, last], options)
    end

    desc 'open NAME', "Open the person's log file"
    map 'open' => 'open_file'
    def open_file(name)
      execute_subcommand(:open_file, name, options)
    end

    desc 'report NAME', 'Create a HTML report for the person'
    def report(name)
      execute_subcommand(:report, name, options)
    end

    desc 'report_team TEAM', 'Create a HTML report for the team'
    def report_team(team)
      execute_subcommand(:report_team, team, options)
    end

    desc 'team_meeting TEAM', 'Insert the same diary entry for every person on the team'
    map 'team' => 'team_meeting'
    def team_meeting(team)
      execute_subcommand(:team_meeting, team, options)
    end

    private

    def do_with_interrupt_handling
      yield if block_given?
    rescue RuntimeError => e
      project_root = File.expand_path("#{__dir__}/..")
      warn HighLine.color("\nAborting, fatal error, #{e} at #{e.backtrace.first.gsub(project_root, '.')}", :red)
      Kernel.exit(1)
    rescue Interrupt
      warn HighLine.color("\nAborting, interrupt received", :red)
      Kernel.exit(2)
    end

    def parameter_to_command_class(parameter)
      self.class.class_eval do
        require_relative 'mt_data_formatter'
        include MtDataFormatter
      end
      command_class_name = parameter.to_s.tr('_', ' ').titlecase.tr(' ', '')
      Kernel.const_get("#{command_class_name}Command")
    end

    def execute_subcommand(subcommand_name, arguments, options)
      subcommand_class = parameter_to_command_class(subcommand_name)
      subcommand = subcommand_class.new
      do_with_interrupt_handling { subcommand.command(arguments, options) }
    end

    def record_diary_entry(subcommand, arguments, options)
      diary = RecordDiaryEntryCommand.new
      do_with_interrupt_handling { diary.command(subcommand.to_sym, arguments, options) }
    end
  end
end
