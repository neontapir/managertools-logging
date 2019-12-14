# frozen_string_literal: true

require_relative '../diary'
require_relative '../employee'
require_relative '../entries/interview_entry'
require_relative '../settings'
require_relative 'new_hire_command'

# Records an interview entry.
# Unlike the RecordDiaryEntryCommand, this will create a new employee entry
#   on the 'candidates' team if the subject isn't found.
class InterviewCommand
  include Diary

  # @!method command(arguments, options)
  #   Record a new diary entry in the person's file
  def command(arguments, options = nil)
    raise 'missing person name argument' unless arguments.first

    employee = Employee.find(arguments.join(' '))
    unless employee
      nhc_args = [Settings.candidates_root] + arguments
      employee = NewHireCommand.new.command(nhc_args, options)
    end

    entry = get_entry(:interview, employee)
    employee.file.insert entry
  end
end
