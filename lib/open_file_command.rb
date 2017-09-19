# frozen_string_literal: true

require_relative 'diary'

include Diary

# Open a person's log file
class OpenFileCommand
  def command(arguments)
    person = arguments.first
    employee = Employee.get person
    log_file = employee.file
    log_file.ensure_exists
    exec("open '#{log_file}'")
  end
end
