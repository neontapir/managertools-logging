require 'facets/string/titlecase'
require 'highline/import'
require 'shell'
require_relative 'mt_data_formatter'
require_relative 'team'

extend MtDataFormatter

# Create a report of a team, using each member's files
class ReportTeamCommand

  # Append a member's report to the team file
  def append_file(destination, contents)
    open(destination, 'a') do |f|
      f.puts contents
      f.puts "\n"
    end
  end

  HORIZONTAL_RULE = "'''".freeze

  # Create a report of a team, using each member\'s files
  def command(arguments)
    team_name = arguments.first
    team = Team.find team_name

    report_name = "team-#{unidown team_name}-report"
    report_source = "#{report_name}.adoc"
    output = "#{report_name}.html"

    [output, report_source].each do |file|
      File.delete file if File.exist? file
    end

    append_file(report_source, "= Team #{team_name.titlecase}\n\n")
    team.members_by_folder.each do |tm|
      append_file(report_source, "include::#{tm}/overview.adoc[]\n\n#{HORIZONTAL_RULE}\n\n")
    end

    system('asciidoctor', "-o#{output}", report_source)
    system('open', output) # for Mac, use "cmd /c" for Windows
  end
end
