# frozen_string_literal: true

require_relative 'file_writer'
require_relative 'mt_data_formatter'
require_relative 'os_adapter'
require_relative 'team'

# Create a report of a team, using each member's files
class ReportTeamCommand
  extend MtDataFormatter
  include FileWriter
  include OSAdapter

  # A horizontal rule in Asciidoc
  HORIZONTAL_RULE = "'''"

  # @!method command(arguments, options)
  #   Create a report of a team, using each member\'s files
  def command(arguments, options = nil)
    team_name = Array(arguments).first
    raise 'missing team name argument' unless team_name

    team = Team.find team_name

    report_name = "team-#{team.to_s.downcase}-report"
    report_source = "#{report_name}.adoc"
    output = "#{report_name}.html"
    generate_report(team, report_source, output)
    command_line = [OSAdapter.open, output].join(' ')
    raise ArgumentError, "Report launch failed with '#{command_line}'" unless system(command_line)
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
end
