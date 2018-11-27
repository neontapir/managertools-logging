# frozen_string_literal: true

require 'highline/import'
require 'shell'
require_relative 'diary'
require_relative 'employee'

# Create a report from a person's files
class ReportCommand
  include Diary

  # Create a report from a person's files
  def command(arguments)
    person = Array(arguments).first
    raise 'missing person argument' unless person
    employee = Employee.get person
    output = generate_report_for employee
    raise ArgumentError, 'Report launch failed' \
      unless system('open', output) # for Mac, use 'cmd /c' for Windows
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
      append_file(report_source, file)
    end

    raise ArgumentError, 'Report launch failed' \
      unless system('asciidoctor', "-o#{output}", report_source)
    output
  end

  def append_file(destination, input)
    contents = IO.read(input)
    open(destination, 'a') do |file|
      file.puts contents
      file.puts "\n"
    end
  end
end
