# frozen_string_literal: true

require 'highline'
require 'thor'
require_relative 'path_string_extensions'
require_relative 'settings'
require_relative 'string_extensions'
Dir["#{__dir__}/commands/*_command.rb"].each { |f| require_relative(f) }

# Module containing the heart of the program
module ManagerTools
  using PathStringExtensions
  using StringExtensions

  # Defines the command-line interface
  # @private
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    config_file = Settings.config_file
    unless File.exist? config_file
      warn HighLine.color("Configuration not found at #{config_file}, run 'mt init' to create it", :red)
    end

    package_name 'Manager Tools'

    desc 'feedback NAME', 'Add a feedback log entry'
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map 'fb' => 'feed'
    map 'feed' => 'feed'

    def feedback(*names)
      record_diary_entry(:feedback, Array(names), options)
    end

    desc 'goal NAME', "Add a goal log entry to each person's file"
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'

    def goal(*names)
      record_diary_entry(:goal, Array(names), options)
    end

    desc 'obs NAMES', 'Add an observation log entry'
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map 'ob' => 'observation'
    map 'obs' => 'observation'

    def observation(*names)
      record_diary_entry(:observation, Array(names), options)
    end

    desc 'o3 NAME', 'Add an 1:1 log entry'
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map '3o' => 'one_on_one'
    map 'o3' => 'one_on_one'
    map 'ooo' => 'one_on_one'

    def one_on_one(name)
      record_diary_entry(:one_on_one, Array(name), options)
    end

    desc 'perf NAME', 'Add a performance checkpoint log entry'
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map 'check' => 'performance_checkpoint'
    map 'perf' => 'performance_checkpoint'

    def performance_checkpoint(name)
      record_diary_entry(:performance_checkpoint, Array(name), options)
    end

    desc 'pto NAMES', 'Add an PTO entry'
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'
    map 'pto' => 'paid_time_off'

    def paid_time_off(*names)
      record_diary_entry(:pto, Array(names), options)
    end

    desc 'depart NAME', "Move the person's files to the departed team"

    def depart(*names)
      execute_subcommand(:depart, Array(names), options)
    end

    desc 'gen', 'Create overview files'
    method_option :force, type: :boolean, default: false, desc: 'Overwrite files if they exist'
    map 'gen' => 'generate_overview_files'

    def generate_overview_files
      execute_subcommand(:generate_overview_files, [], options)
    end

    desc 'interview CANDIDATE', 'Add an interview log entry'
    method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'

    def interview(*candidate)
      execute_subcommand(:interview, Array(candidate), options)
    end

    desc 'latest NAME', "Display the person's latest log entry"
    map 'last' => 'last_entry'
    map 'latest' => 'last_entry'

    def last_entry(name)
      execute_subcommand(:last_entry, Array(name), options)
    end

    desc 'move TEAM *NAMES', "Move the people's files to the specified team"
    map 'move' => 'move_team'

    def move_team(team, *names)
      execute_subcommand(:move_team, [team, names], options)
    end

    desc 'new TEAM FIRST LAST', "Create the person's overview and log files in the given team folder"
    method_option :force, type: :boolean, default: false, desc: 'Overwrite files if they exist'
    map 'add' => 'new_hire'
    map 'create' => 'new_hire'
    map 'new' => 'new_hire'

    def new_hire(team, first, last)
      execute_subcommand(:new_hire, [team, first, last], options)
    end

    desc 'new-project PROJECT', 'Create the projects log file in the project root'
    method_option :force, type: :boolean, default: false, desc: 'Overwrite files if they exist'
    
    def new_project(project)
      execute_subcommand(:new_project, project, options)
    end

    desc 'new-team TEAM', "Create the team's folder in the data root"

    def new_team(team)
      execute_subcommand(:new_team, team, options)
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

    desc 'sentiment NAME', 'Do sentiment analysis on the person\'s log file'

    def sentiment(name)
      execute_subcommand(:sentiment, name, options)
    end

    desc 'team_meeting TEAMS', 'Insert the same diary entry for every person on the given teams'
    map 'team' => 'team_meeting'

    def team_meeting(*teams)
      execute_subcommand(:team_meeting, teams, options)
    end

    desc 'init', 'Create a new config file'

    def init
      execute_subcommand(:init, [], options)
    end

    private

    # the project's root file should be the parent of the current folder
    def project_root
      File.expand_path("#{__dir__}/..")
    end

    # used for friendly error messages, so entire stack trace is not displat\yed
    def error_call_site(error)
      error.backtrace.first.gsub(project_root, '.')
    end

    # wrap the call with interrupt handling, for consistent error display
    def do_with_interrupt_handling
      yield if block_given?
    rescue StandardError => e
      warn HighLine.color("\nAborting, fatal #{e.class}, #{e} at #{error_call_site(e)}", :red)
      Kernel.exit(3)
    rescue Interrupt
      warn HighLine.color("\nAborting, interrupt received", :red)
      Kernel.exit(2)
    rescue RuntimeError => e
      warn HighLine.color("\nAborting, fatal unhandled error, #{e} at #{error_call_site(e)}", :red)
      Kernel.exit(1)
    end

    # convert a symbol into a command class
    def to_command(symbol)
      command_class_name = symbol.to_s.path_to_name.tr(' ', '')
      Kernel.const_get("#{command_class_name}Command")
    end

    # run the given subcommand
    def execute_subcommand(subcommand_name, arguments, options)
      subcommand = to_command(subcommand_name).new
      do_with_interrupt_handling { subcommand.command(arguments, options) }
    end

    # the default action, write a template to the person's file
    def record_diary_entry(subcommand, arguments, options)
      diary = RecordDiaryEntryCommand.new
      do_with_interrupt_handling { diary.command(subcommand.to_sym, arguments, options) }
    end
  end
end
