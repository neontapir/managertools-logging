# frozen_string_literal: true

require_relative '../diary'
require_relative '../employee'
require_relative '../string_extensions'

# Implements diary recording functionality
class RecordDiaryEntryCommand
  include Diary
  using StringExtensions

  # @!method command(arguments, options)
  #   Record a new diary entry in the person's file
  def command(subcommand, arguments, options = nil)
    @command_opts ||= options
    raise 'missing person name argument' unless arguments.first

    log_message(to_employees(arguments), subcommand.to_sym)
  end

  private

  # takes a list of employee specs and converts it into employee objects
  def to_employees(arguments)
    arguments.map do |person|
      employee = Employee.find(person)
      raise EmployeeNotFoundError, "unable to find employee '#{person}'" unless employee

      employee
    end
  end

  # logs a message to each employee's file
  def log_message(members, entry_type)
    entry = nil
    members.each do |employee|
      entry ||= get_entry(
        entry_type,
        members.join(','),
        applies_to: members
          .map { |m| m.to_s.to_name }
          .join(', ')
      )
      employee.file.insert entry
    end
  end
end
