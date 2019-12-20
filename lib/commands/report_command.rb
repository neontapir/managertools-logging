# frozen_string_literal: true

require 'asciidoctor'
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
  def command(arguments, options = nil)
    no_launch = (options&.no_launch == true)

    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    output = generate_report_for employee
    command_line = [OSAdapter.open_command, output].join(' ')
    return if no_launch

    raise ArgumentError, "Report launch failed with '#{command_line}'" unless system(command_line)
  end

  private

  # gemerates a report for an employee
  def generate_report_for(employee)
    _ = EmployeeFolder.new employee
    overview_file = employee.overview_location
    log_file = employee.file.to_s
    create_report(employee.canonical_name, overview_file, log_file)
  end

  # calls Asciidoctor to convert the report template to HTML
  def create_report(employee_name, overview_file, log_file)
    report_source = create_report_source(employee_name, overview_file, log_file)
    output = "report-#{employee_name}.html"
    File.delete output if File.exist? output

    raise StandardError, 'Report launch failed' unless system('asciidoctor', "-o#{output}", report_source)

    output
  end

  # builds a report template for Asciidoctor
  def create_report_source(employee_name, overview_file, log_file)
    report_source = "report-#{employee_name}.adoc"
    File.delete report_source if File.exist? report_source

    [overview_file, log_file].each do |file|
      append_file(report_source, "include::#{file}[]")
    end

    report_source
  end
end
