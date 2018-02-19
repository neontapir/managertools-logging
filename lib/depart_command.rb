# frozen_string_literal: true

require 'fileutils'

require_relative 'employee_finder'
require_relative 'settings'

# Mark a person departed by moving their data to the departed records folder
class DepartCommand
  include EmployeeFinder

  def command(arguments)
    search_term = Array(arguments).first
    employee = find(search_term)
    raise ArgumentError, "No employee matching '#{search_term}' found, aborting" unless employee

    folder = File.dirname employee.file.path
    if employee.team == Settings.departed_root
      puts "#{employee} has already been marked as departed"
    else
      puts "Marking #{employee} as departed"
      FileUtils.move(folder, "#{Settings.root}/#{Settings.departed_root}")
    end
  end
end
