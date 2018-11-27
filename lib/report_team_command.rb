# frozen_string_literal: true

require 'facets/string/titlecase'
require 'highline/import'
require 'shell'
require_relative 'mt_data_formatter'
require_relative 'team'

# Create a report of a team, using each member's files
class ReportTeamCommand
  extend MtDataFormatter
  HORIZONTAL_RULE = "'''"

  # Create a report of a team, using each member\'s files
  def command(arguments)
    team_name = arguments.first
    raise 'missing team name argument' unless team_name

    team = Team.find team_name

    report_name = "team-#{team}-report"
    report_source = "#{report_name}.adoc"
    output = "#{report_name}.html"
    generate_report(team, report_source, output)
    raise ArgumentError, 'Report launch failed' \
      unless system('open', output) # for Mac, use "cmd /c" for Windows
  end

  private

  def generate_report(team, report_source, output)
    [report_source, output].each do |file|
      File.delete file if File.exist? file
    end

    append_file(report_source, "= Team #{team.to_s.titlecase}\n\n")
    team.members_by_folder.each do |tm|
      append_file(report_source, "include::#{tm}/overview.adoc[]\n\n#{HORIZONTAL_RULE}\n\n")
    end

    raise ArgumentError, 'Asciidoctor launch failed' \
      unless system('asciidoctor', "-o#{output}", report_source)
  end

  # Append a member's report to the team file
  def append_file(destination, contents)
    open(destination, 'a') do |file|
      file.puts contents
      file.puts "\n"
    end
  end
end
