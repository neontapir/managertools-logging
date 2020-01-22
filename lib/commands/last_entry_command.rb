# frozen_string_literal: true

require 'fileutils'

require_relative '../entries/diary_entry'
require_relative '../employee_finder'
require_relative 'mt_command'
require_relative '../settings'

# Allows printing of a log file's latest entry
class LastEntryCommand < MtCommand
  include EmployeeFinder

  # command(arguments, options)
  #   Print the latest entry in the file
  #   @raise [EmployeeNotFoundError]
  def command(arguments, _ = nil)
    search_term = Array(arguments).first
    employee = find search_term
    raise EmployeeNotFoundError, "No employee matching '#{search_term}' found, aborting" unless employee

    log_file = employee.file.path
    last = []
    File.readlines(log_file).each do |line|
      last.clear if line[DiaryEntry::ENTRY_HEADER_MARKER]
      last << line
    end
    puts last.join
  end
end
