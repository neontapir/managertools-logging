#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optimist'
Dir["#{__dir__}/lib/*_command.rb"].each { |f| require_relative(f) }

ALIASES = {
  '3o' => 'o3',
  'bulk' => 'multiple-member',
  'check' => 'performance-checkpoint',
  'fb' => 'feedback',
  'feed' => 'feedback',
  'gen' => 'generate-overview-files',
  'last' => 'last-entry',
  'meeting' => 'team-meeting',
  'move' => 'move-team',
  'multi' => 'multiple-member',
  'ob' => 'observation',
  'obs' => 'observation',
  'ooo' => 'o3',
  'open' => 'open-file',
  'perf' => 'performance-checkpoint',
  'team' => 'team-meeting'
}.freeze

BANNERS = {
  'feedback' => 'Add a feedback entry for a direct report',
  'goal' => 'Add a development goal for one or more direct reports',
  'interview' => 'Add an interview entry for a candidate',
  'o3' => 'Add a one-on-one entry for a direct report',
  'observation' => 'Make an observation about a person'
}.freeze

def parameter_to_command_class(parameter)
  require_relative 'lib/mt_data_formatter'
  include MtDataFormatter
  command_class_name = parameter.tr('-', ' ').titlecase.tr(' ', '')
  Kernel.const_get("#{command_class_name}Command")
end

def execute_subcommand(subcommand_name, arguments)
  subcommand_class = parameter_to_command_class(subcommand_name)
  subcommand = subcommand_class.new
  subcommand.command arguments
end

def record_diary_entry(subcommand, arguments)
  # capture options given after subcommand
  @cmd_opts = Optimist.options do
    banner BANNERS[subcommand]
    opt :template, 'Create blank template entry', short: '-t'
  end
  diary = RecordDiaryEntryCommand.new @global_opts, @cmd_opts
  diary.command subcommand.to_sym, arguments
end

def parse(script, subcommand, arguments)
  # in cases where a command alias is given, re-parse using the canonical name
  if ALIASES.key?(subcommand)
    script = parse(script, ALIASES[subcommand], arguments)
  # in cases where we're just adding an entry, invoke module directly
  elsif %w[feedback interview o3 observation performance-checkpoint].include?(subcommand)
    record_diary_entry(subcommand, arguments)
    exit
  # in cases where we will invoke a command class
  elsif %w[depart generate-overview-files goal last-entry move-team multiple-member new-hire  
           open-file report report-team team-meeting].include?(subcommand)
    execute_subcommand(subcommand, arguments)
    exit
  else
    Optimist.die "unknown subcommand #{subcommand.inspect}"
  end
  script
end

CSV_DELIMITER = ', '

def display(hash)
  hash.map { |k, v| "#{k} -> #{v}" }.join(CSV_DELIMITER)
end

if $PROGRAM_NAME == __FILE__
  SUB_COMMANDS = %w[feedback gen-overview-files interview last-entry move-team
                    multiple-member new-hire o3 observation performace-checkpoint
                    report report-team team-meeting].freeze

  # capture options given before subcommand
  # TODO: there's a bug here in the way arguments to subcommands are parsed
  #   for example, './mt gen --force' returns an error
  @global_opts = Optimist.options do
    banner 'Command-line note-taking system based on Manager Tools practices'
    banner "Subcommands are: #{SUB_COMMANDS.sort * CSV_DELIMITER}"
    banner "Aliases are: #{display ALIASES.sort}"
    # opt :dry_run, "Don't actually do anything", :short => "-n"
    opt :template, 'Create blank template entry', short: '-t'
    stop_on SUB_COMMANDS
  end

  subcommand = ARGV.shift
  script = parse(__dir__, subcommand, ARGV)
  system %W["#{script} #{ARGV.join(' ')}"]
end
