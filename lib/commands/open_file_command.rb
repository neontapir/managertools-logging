# frozen_string_literal: true

require_relative '../diary'
require_relative 'mt_command'
require_relative '../os_adapter'

# Open a person's log file.
class OpenFileCommand < MtCommand
  include Diary
  include OSAdapter

  # command(arguments, options)
  #   Open a person's log file in the default editor
  #   @raise [IOError]
  def command(arguments, _ = nil)
    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    log_file = employee.file
    log_file.ensure_exists
    command_line = [OSAdapter.open_command, log_file.to_s].join(' ')
    raise IOError, "Log file open failed with '#{command_line}'" unless system(command_line)
  end
end
