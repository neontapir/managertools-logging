require_relative '../diary'
require_relative '../employee'
require_relative '../entries/interview_entry'
require_relative '../mt_data_formatter'
require_relative '../settings'
require_relative 'new_hire_command'

require 'pry'

# Implements diary recording functionality
class InterviewCommand
  include Diary
  include MtDataFormatter

  # @!method command(arguments, options)
  #   Record a new diary entry in the person's file
  def command(arguments, options = nil)
    raise 'missing person name argument' unless arguments.first

    person = arguments.join(' ')
    employee = Employee.find(person)
    unless employee
      nhc_args = [Settings.candidates_root] + arguments
      employee = NewHireCommand.new.command(nhc_args, options)
    end

    entry = get_entry(:interview, employee)
    employee.file.insert entry
  end
end