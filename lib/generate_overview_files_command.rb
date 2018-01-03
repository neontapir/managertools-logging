# frozen_string_literal: true

require 'pathname'
require 'facets/string/titlecase'
require_relative 'employee'
require_relative 'employee_folder'
require_relative 'mt_data_formatter'
require_relative 'new_hire_command'
require_relative 'path_splitter'

# Generate overview files recrusively for entries in the data folder
class GenerateOverviewFilesCommand
  extend MtDataFormatter
  extend PathSplitter

  # Generate the files needed to create a team overview
  def command(arguments)
    force = false
    if arguments.first == '--force'
      force = true
      arguments.shift
    end

    new_hire = NewHireCommand.new
    Dir.glob("#{EmployeeFolder.root}/*/*") do |folder|
      unless force
        next unless Dir.exist?(folder)
      end
      nhc_args = get_nhc_args(folder)
      new_hire.command(nhc_args)
    end
  end

  private

  def get_nhc_args(folder)
    employee = Employee.find(folder)
    nhc_args = [employee.team, employee.first, employee.last]
    nhc_args
  end
end
