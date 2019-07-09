#!/usr/bin/env ruby
# frozen_string_literal: true

require 'commander'
require 'highline'
Dir["#{__dir__}/lib/*_command.rb"].each { |f| require_relative(f) }

class ManagerTools
  include Commander::Methods

  def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def setup
    program :name, 'Manager Tools'
    program :version, '2019.07.05'
    program :description, 'Command-line note-taking system based on Manager Tools practices'

    command :feedback do |c|
      diary_entry_command(c, :feedback)
    end
    alias_command :fb, :feedback
    alias_command :feed, :feedback
    
    command :interview do |c|
      diary_entry_command(c, :interview)
    end
    
    command :observation do |c|
      diary_entry_command(c, :observation)
    end
    alias_command :ob, :observation
    alias_command :obs, :observation
    
    command :one_on_one do |c|
      diary_entry_command(c, :one_on_one)
    end
    alias_command :'3o', :one_on_one
    alias_command :o3, :one_on_one
    alias_command :ooo, :one_on_one

    command :performance_checkpoint do |c|
      diary_entry_command(c, :performance_checkpoint)
    end
    alias_command :check, :performance_checkpoint
    alias_command :perf, :performance_checkpoint

    command :depart do |c|
      c.syntax = "mt depart [person]"
      c.description = "Moves files for the person to the departed team, #{Settings.departed_root}"
      c.action do |args, options|
        execute_subcommand(:depart, args, options)
      end
    end
    alias_command :move, :move_team

    command :generate_overview_files do |c|
      c.syntax = "mt gen"
      c.description = 'Generates overview files'
      c.option '--force', 'Overwrite files if they exist'
      c.action do |args, options|
        execute_subcommand(:generate_overview_files, args, options)
      end
    end
    alias_command :gen, :generate_overview_files

    command :last_entry do |c|
      c.syntax = "mt last [person]"
      c.description = 'Displays the latest entry for the first person found matching the name specification'
      c.action do |args, options|
        execute_subcommand(:last_entry, args, options)
      end
    end
    alias_command :last, :last_entry
    alias_command :latest, :last_entry
    
    command :move_team do |c|
      c.syntax = "mt move [person] [new-team]"
      c.description = 'Moves files for the person to the specified team, both found by specification'
      c.action do |args, options|
        execute_subcommand(:move_team, args, options)
      end
    end
    alias_command :move, :move_team
    
    command :new_hire do |c|
      c.syntax = "mt new [team] [first-name] [last-name]"
      c.description = 'Generates overview and log files for the new person'
      c.option '--force', 'Overwrite files if they exist'
      c.action do |args, options|
        execute_subcommand(:new_hire, args, options)
      end
    end
    
    command :open_file do |c|
      c.syntax = "mt open [name-spec]"
      c.description = 'Opens the log file for the first person found matching the name specification'
      c.action do |args, options|
        execute_subcommand(:open_file, args, options)
      end
    end
    
    command :report do |c|
      c.syntax = "mt report [name-spec]"
      c.description = 'Generates a HTML report for the first person found matching the name specification'
      c.action do |args, options|
        execute_subcommand(:report, args, options)
      end
    end
    
    command :report_team do |c|
      c.syntax = "mt report_team [team-spec]"
      c.description = 'Generates a HTML team report for the first team found matching the team name specification'
      c.action do |args, options|
        execute_subcommand(:report_team, args, options)
      end
    end
    
    command :team_meeting do |c|
      c.syntax = "mt team_meeting [team-spec]"
      c.description = 'Inserts the same diary entry for every person in the team found matching the team name specification'
      c.action do |args, options|
        execute_subcommand(:team_meeting, args, options)
      end
    end
    alias_command :team, :team_meeting
  end

  def execute!
    setup
    run!
  end

  private

  def do_with_interrupt_handling
    yield
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

  def diary_entry_command(c, entry_type)
    entry_type_string = entry_type.to_s.tr('_',' ')
    c.syntax = "mt #{entry_type_string} [name-spec]"
    c.description = "Adds a #{entry_type_string} entry for the first person found matching the name specification"
    c.option '--template', 'Add a template to the log file, without entry data'
    c.action do |args, options|
      record_diary_entry(entry_type, args, options)
    end
  end
end

ManagerTools.new(ARGV.dup).execute! if $PROGRAM_NAME == __FILE__
