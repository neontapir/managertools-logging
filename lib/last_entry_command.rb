# frozen_string_literal: true

require 'fileutils'

require_relative 'employee_finder'
require_relative 'settings'

class LastEntryCommand
  include EmployeeFinder

  def command(arguments)
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
