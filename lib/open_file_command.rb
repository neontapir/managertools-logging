# frozen_string_literal: true

require_relative 'diary'

# Open a person's log file
class OpenFileCommand
  include Diary

  def command(arguments)
    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    log_file = employee.file
    log_file.ensure_exists
    system 'open', log_file.to_s
  end
end
