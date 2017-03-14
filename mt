#!/usr/bin/env ruby

require 'trollop'

def feedback
  person = ARGV[0]
  record_to_file :feedback, person
end

def record_diary_entry(entry_type, person)
  require_relative 'lib/diary'
  include Diary
  record_to_file entry_type, person
end

ALIASES = {
  'new' => 'new-hire',
  'gen' => 'gen-overview-files',
  'ob' => 'observation',
  'obs' => 'observation',
  'open' => 'open-file',
  'feed' => 'feedback',
  'fb' => 'feedback',
  'team' => 'team-meeting',
  'meeting' => 'team-meeting'
}.freeze

def add_entry(subcommand, arguments)
  banners = {
    'feedback' => 'Add a feedback entry for a direct report',
    'interview' => 'Add an interview entry for a candidate',
    'o3' => 'Add a one-on-one entry for a direct report',
    'observation' => 'Make an observation about a person'
  }
  # capture options given after subcommand
  @cmd_opts = Trollop.options do
    banner banners[subcommand]
    opt :template, 'Create blank template entry', short: '-t'
  end
  record_diary_entry subcommand.to_sym, arguments[0]
  exit
end

def parse(script, subcommand, arguments)
  if ALIASES.key?(subcommand)
    # script = File.join(script, ALIASES[subcommand])
    parse(script, ALIASES[subcommand], arguments)
  elsif %w(report report-team).include?(subcommand)
    script = File.join(script, subcommand)
  # in cases where we're just adding an entry, invoke module directly
  elsif %w(feedback interview o3 observation).include?(subcommand)
    add_entry(subcommand, arguments)
  elsif ALIASES.values.include?(subcommand)
    script = File.join(script, subcommand)
  else
    Trollop.die "unknown subcommand #{subcommand.inspect}"
  end
  script
end

CSV_DELIMITER = ', '.freeze

def display(hash)
  hash.map { |k, v| "#{k} -> #{v}" }.join(CSV_DELIMITER)
end

if __FILE__ == $PROGRAM_NAME
  script = File.dirname(File.realpath(__FILE__))
  SUB_COMMANDS = %w(feedback gen-overview-files interview team-meeting new-hire
                    o3 observation report report-team).freeze

  # capture options given before subcommand
  @global_opts = Trollop.options do
    banner 'Command-line note-taking system based on Manager Tools practices'
    banner "Subcommands are: #{SUB_COMMANDS.sort * CSV_DELIMITER}"
    banner "Aliases are: #{display(ALIASES)}"
    # opt :dry_run, "Don't actually do anything", :short => "-n"
    opt :template, 'Create blank template entry', short: '-t'
    stop_on SUB_COMMANDS
  end

  subcommand = ARGV.shift
  script = parse script, subcommand, ARGV
  exec("#{script} #{ARGV.join(' ')}")
end
