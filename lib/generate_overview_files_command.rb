# frozen_string_literal: true

require 'pathname'
require_relative 'employee'
require_relative 'employee_folder'
require_relative 'mt_data_formatter'
require_relative 'new_hire_command'
require_relative 'path_formatter'

# Generate overview files recrusively for entries in the data folder
class GenerateOverviewFilesCommand
  extend MtDataFormatter
  extend PathFormatter

  # @!method command(arguments, options)
  #   Generate the files needed to create a team overview
  def command(_, options = nil)
    force = (options&.force == true)

    new_hire = NewHireCommand.new
    Dir.glob("#{EmployeeFolder.root}/*/*") do |folder|
      unless force
        next unless Dir.exist? folder
      end
      nhc_args = get_nhc_args folder
      new_hire.command nhc_args
    end
  end

  private

  def get_nhc_args(folder)
    employee = Employee.find folder
    nhc_args = [employee.team, employee.first, employee.last]
    nhc_args
  end
end
