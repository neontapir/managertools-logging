# frozen_string_literal: true

require_relative '../diary'
require_relative '../employee'
require_relative '../file_writer'
require_relative '../os_adapter'

# Create a report from a person's files
class ReportCommand
  include Diary
  include FileWriter
  include OSAdapter

  # Create a report from a person's files
  def command(arguments, _ = nil)
    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    output = generate_report_for employee
    command_line = [OSAdapter.open_command, output].join(' ')
    raise ArgumentError, "Report launch failed with '#{command_line}'" unless system(command_line)
  end

  private

  def generate_report_for(employee)
    folder = EmployeeFolder.new employee
    overview_file = File.join(folder.path, 'overview.adoc')
    log_file = (LogFile.new folder).to_s
    employee_name = employee.canonical_name
    create_report(employee_name, overview_file, log_file)
  end

  def create_report(employee_name, overview_file, log_file)
    report_source = "report-#{employee_name}.adoc"
    output = "report-#{employee_name}.html"
    [report_source, output].each do |file|
      File.delete file if File.exist? file
    end

    [overview_file, log_file].each do |file|
      append_file(report_source, "include::#{file}[]")
    end

    raise StandardError, 'Report launch failed' \
      unless system('asciidoctor', "-o#{output}", report_source)

    output
  end
end
