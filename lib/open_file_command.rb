# frozen_string_literal: true

require_relative 'diary'

# Open a person's log file.
class OpenFileCommand
  include Diary

  def command(arguments)
    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    log_file = employee.file
    log_file.ensure_exists
    raise ArgumentError, 'Settings.editor launch failed, is it configured?' \
      unless system Settings.editor, log_file.to_s
  end
end
