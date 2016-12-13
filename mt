#!/usr/bin/env ruby

require 'trollop'

def record_diary_entry(entry_type, person)
  require_relative 'lib/diary'
  include Diary
  record_to_file entry_type, person
end

ALIASES = {
  "new" => "new-hire",
  "gen" => "gen-overview-files",
  "ob" => "observation",
  "obs" => "observation",
  "open" => "open-file",
  "feed" => "feedback",
  "fb" => "feedback"
}

def parse(script, subcommand, arguments)
  case
    when ALIASES.values.include?(subcommand)
      script = File.join(script, subcommand)
    when ALIASES.key?(subcommand)
      script = File.join(script, ALIASES[subcommand])
    when ["report", "report-team"].include?(subcommand)
      script = File.join(script, subcommand)
    # in cases where we're just adding an entry, invoke module directly
    when ["interview", "o3"].include?(subcommand)
      # capture options given after subcommand
      @cmd_opts = Trollop::options do
        opt :template, "Create blank template entry", :short => "-t"
      end
      record_diary_entry subcommand.to_sym, arguments[0]
      exit
    else
      Trollop::die "unknown subcommand #{subcommand.inspect}"
  end
  script
end

if __FILE__==$0
  script = File.dirname(File.realpath(__FILE__))
  SUB_COMMANDS = %w(feedback gen interview meet new o3 observe report report-team)

  # capture options given before subcommand
  @global_opts = Trollop::options do
    banner "Manager Tools"
    #opt :dry_run, "Don't actually do anything", :short => "-n"
    opt :template, "Create blank template entry", :short => "-t"
    stop_on SUB_COMMANDS
  end

  subcommand = ARGV.shift
  script = parse script, subcommand, ARGV
  exec("#{script} #{ARGV.join(' ')}")
end
