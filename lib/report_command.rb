# frozen_string_literal: true

require 'highline/import'
require 'shell'
require_relative 'diary'
require_relative 'employee'

include Diary

# Create a report from a person's files
class ReportCommand
  # Create a report from a person's files
  def command(arguments)
    person = arguments.first
    raise "missing person argument" unless person
    
    employee = Employee.get person
    output = generate_report_for employee
    system('open', output) # for Mac, use 'cmd /c' for Windows
  end

  private

  def generate_report_for(employee)
    folder = EmployeeFolder.new employee
    folder.ensure_exists

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

    append_file(report_source, overview_file)
    append_file(report_source, log_file)

    system('asciidoctor', "-o#{output}", report_source)
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
