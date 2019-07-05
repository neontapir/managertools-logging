# frozen_string_literal: true

require 'fileutils'

require_relative 'employee_finder'
require_relative 'settings'

# Allows printing of a log file's latest entry
class LastEntryCommand
  include EmployeeFinder

  # @!method command(arguments, options)
  #   Print the latest entry in the file
  def command(arguments, options = nil)
    search_term = Array(arguments).first
    employee = find search_term
    raise ArgumentError, "No employee matching '#{search_term}' found, aborting" unless employee

    log_file = employee.file.path
    last = []
    File.readlines(log_file).each do |line|
      last.clear if line['=== ']
      last << line
    end
    puts last.join
  end
end
