require 'highline/import'
require 'shell'
require_relative 'diary'
require_relative 'employee'

include Diary

# Create a report from a person's files
class ReportCommand
  def append_file(destination, input)
    contents = IO.read(input)
    open(destination, 'a') do |f|
      f.puts contents
      f.puts "\n"
    end
  end

  # Create a report from a person's files
  def command(arguments)
    person = arguments.first
    employee = Employee.get person
    employee_name = employee.canonical_name

    folder = EmployeeFolder.new employee
    folder.ensure_exists

    overview_file = File.join(folder.path, 'overview.adoc')
    log_file = (LogFile.new folder).to_s

    report_source = "report-#{employee_name}.adoc"
    output = "report-#{employee_name}.html"
    [report_source, output].each do |file|
      File.delete file if File.exist? file
    end

    append_file(report_source, overview_file)
    append_file(report_source, log_file)

    system('asciidoctor', "-o#{output}", report_source)
    system('open', output) # for Mac, use 'cmd /c' for Windows
  end
end