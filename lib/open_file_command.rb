# frozen_string_literal: true

require_relative 'diary'
require_relative 'os_adapter'

# Open a person's log file.
class OpenFileCommand
  include Diary
  include OSAdapter

  def command(arguments)
    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    log_file = employee.file
    log_file.ensure_exists
    command_line = [OSAdapter.open, log_file.to_s].join(' ')
    raise ArgumentError, "Log file open failed with '#{command_line}'" unless system(command_line)
  end
end
