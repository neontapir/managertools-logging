# frozen_string_literal: true

require 'pathname'
require_relative '../employee'
require_relative '../employee_folder'
require_relative '../path_string_extensions'
require_relative 'mt_command'
require_relative 'new_hire_command'

# Generate overview files recrusively for entries in the data folder
class GenerateOverviewFilesCommand < MtCommand
  using PathStringExtensions

  # Generate the files needed to create a team overview
  def command(_, options = nil)
    force = (options&.force == true)

    new_hire = NewHireCommand.new
    Dir.glob("#{EmployeeFolder.root}/*/*") do |folder|
      next unless (force || Dir.exist?(folder))
      nhc_args = get_nhc_args folder
      new_hire.command nhc_args
    end
  end

  private

  # Get the new hire command arguments
  def get_nhc_args(folder)
    employee = Employee.find folder
    [employee.team, employee.first, employee.last]
  end
end
