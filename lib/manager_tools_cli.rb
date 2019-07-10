# frozen_string_literal: true

require 'highline'
require 'thor'
require_relative 'settings'
Dir["#{__dir__}/*_command.rb"].each { |f| require_relative(f) }

module ManagerTools
  class CLI < Thor
    def self.diary_subcommand(entry_type)
      CLI.class_eval do
        entry_type_string = entry_type.to_s.tr('_',' ')
        n = 'aeiou'.include?(entry_type.to_s[0]) ? 'n' : ''
        eval "desc \"#{entry_type} (name)\", \"Adds a#{n} #{entry_type_string} log entry for the named person.\""
        eval "method_option :template, type: :boolean, default: false, desc: 'Add a template to the log file, without entry data'"
        define_method entry_type do |name_spec|
          record_diary_entry(__method__, Array(name_spec), options)
        end
        yield if block_given?
      end
    end

    def self.exit_on_failure?
      true
    end

    package_name "Manager Tools"

    diary_subcommand :feedback do
      map 'fb': :feedback
      map 'feed': :feedback
    end

    diary_subcommand :interview

    diary_subcommand :observation do
      map 'ob': :observation
      map 'obs': :observation
    end

    diary_subcommand :one_on_one do
      map '3o': :one_on_one
      map 'o3': :one_on_one
      map 'ooo': :one_on_one
    end

    diary_subcommand :performance_checkpoint do
      map 'check': :performance_checkpoint
      map 'perf': :performance_checkpoint
    end

    desc 'depart (name)', "Moves the person's files to the departed team, #{Settings.departed_root}"
    def depart(args)
      execute_subcommand(:depart, args, options)
    end

    desc 'generate_overview_files', 'Generates overview files'
    method_option :force, type: :boolean, default: false, desc: 'Overwrite files if they exist'
    map 'gen': :generate_overview_files
    def generate_overview_files(args)
      execute_subcommand(:generate_overview_files, args, options)
    end

    desc 'last_entry (name)', "Displays the person's latest log entry"
    map 'last': :last_entry
    map 'latest': :last_entry
    def last_entry(args)
      execute_subcommand(:last_entry, args, options)
    end

    desc 'move_team (name) (team)', "Moves the person's files to the specified team"
    def move_team(args)
      map 'move': :move_team
      execute_subcommand(:move_team, args, options)
    end

    desc 'new_hire (team) (first-name) (last-name)', "Generates the person's overview and log files in the given team folder"
    method_option :force, type: :boolean, default: false, desc: 'Overwrite files if they exist'
    map 'new': :new_hire
    def new_hire(args)
      execute_subcommand(:new_hire, args, options)
    end
    
    desc 'open_file (name)', "Opens the person's log file"
    map 'open': :open_file
    def open_file(args)
      execute_subcommand(:open_file, args, options)
    end

    desc 'report (name)', 'Generates a HTML report for the person'
    def report(args)
      execute_subcommand(:report, args, options)
    end

    desc 'report_team (team)', 'Generates a HTML report for the team'
    def report_team(args)
      execute_subcommand(:report_team, args, options)
    end

    desc 'team_meeting (team)', 'Inserts the same diary entry for every person on the team'
    map 'team': :team_meeting
    def team_meeting(args)
      execute_subcommand(:team_meeting, args, options)
    end

    private

    def do_with_interrupt_handling
      yield if block_given?
      rescue Interrupt
        warn HighLine.color("\nAborting, interrupt received", :red)
        @kernel.exit(-1)
    end

    def parameter_to_command_class(parameter)
      self.class.class_eval do
        require_relative 'lib/mt_data_formatter'
        include MtDataFormatter
      end
      command_class_name = parameter.to_s.tr('_', ' ').titlecase.tr(' ', '')
      @kernel.const_get("#{command_class_name}Command")
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
