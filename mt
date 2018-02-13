#!/usr/bin/env ruby
# frozen_string_literal: true

require 'trollop'
Dir["#{__dir__}/lib/*_command.rb"].each { |f| require_relative(f) }

def record_diary_entry(entry_type, person)
  require_relative 'lib/diary'
  include Diary
  record_to_file entry_type, person
end

ALIASES = {
  'fb' => 'feedback',
  'feed' => 'feedback',
  'gen' => 'generate-overview-files',
  'meeting' => 'team-meeting',
  'ob' => 'observation',
  'obs' => 'observation',
  'open' => 'open-file',
  'team' => 'team-meeting'
}.freeze

BANNERS = {
  'feedback' => 'Add a feedback entry for a direct report',
  'interview' => 'Add an interview entry for a candidate',
  'o3' => 'Add a one-on-one entry for a direct report',
  'observation' => 'Make an observation about a person'
}.freeze

def add_entry(subcommand, arguments)
  # capture options given after subcommand
  @cmd_opts = Trollop.options do
    banner BANNERS[subcommand]
    opt :template, 'Create blank template entry', short: '-t'
  end
  record_diary_entry subcommand.to_sym, arguments.first
end

def parameter_to_command_class(parameter)
  require 'facets/string/titlecase'
  command_class_name = parameter.tr('-', ' ').titlecase.tr(' ', '')
  Kernel.const_get("#{command_class_name}Command")
end

def execute_subcommand(subcommand_name, arguments)
  subcommand_class = parameter_to_command_class(subcommand_name)
  subcommand = subcommand_class.new
  subcommand.command arguments
end

def parse(script, subcommand, arguments)
  # in cases where a command alias is given, re-parse using the canonical name
  if ALIASES.key?(subcommand)
    script = parse(script, ALIASES[subcommand], arguments)
  # in cases where we're just adding an entry, invoke module directly
  elsif %w[feedback interview o3 observation].include?(subcommand)
    add_entry(subcommand, arguments)
    exit
  # in cases where we will invoke a command class
  elsif %w[generate-overview-files new-hire open-file report report-team team-meeting].include?(subcommand)
    execute_subcommand(subcommand, arguments)
    exit
  else
    Trollop.die "unknown subcommand #{subcommand.inspect}"
  end
  script
end

CSV_DELIMITER = ', '

def display(hash)
  hash.map { |k, v| "#{k} -> #{v}" }.join(CSV_DELIMITER)
end

if $PROGRAM_NAME == __FILE__
  SUB_COMMANDS = %w[feedback gen-overview-files interview team-meeting new-hire
                    o3 observation report report-team].freeze

  # capture options given before subcommand
  # TODO: there's a bug here in the way arguments to subcommands are parsed
  #   for example, './mt gen --force' returns an error
  @global_opts = Trollop.options do
    banner 'Command-line note-taking system based on Manager Tools practices'
    banner "Subcommands are: #{SUB_COMMANDS.sort * CSV_DELIMITER}"
    banner "Aliases are: #{display ALIASES.sort}"
    # opt :dry_run, "Don't actually do anything", :short => "-n"
    opt :template, 'Create blank template entry', short: '-t'
    stop_on SUB_COMMANDS
  end

  subcommand = ARGV.shift
  script = parse(__dir__, subcommand, ARGV)
  exec("#{script} #{ARGV.join(' ')}")
end
