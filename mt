#!/usr/bin/env ruby

require 'trollop'

if __FILE__==$0
  script = File.dirname(File.realpath(__FILE__))
  SUB_COMMANDS = %w(new gen meet o3 observe)

  global_opts = Trollop::options do
    banner "Manager Tools"
    #opt :dry_run, "Don't actually do anything", :short => "-n"
    stop_on SUB_COMMANDS
  end

  cmd = ARGV.shift # get the subcommand
  case cmd
    when "new"
      script = File.join(script, "new-hire")
    when "gen"
      script = File.join(script, "gen-overview-files")
    when "meet"
      script = File.join(script, "team-meeting")
    when "observe", "ob", "obs"
      script = File.join(script, "observation")
    when "open"
      script = File.join(script, "open-file")
    when "interview", "o3", "feedback", "report", "report-team"
      script = File.join(script, cmd)
    else
      Trollop::die "unknown subcommand #{cmd.inspect}"
  end

  exec("#{script} #{ARGV.join(' ')}")
end
