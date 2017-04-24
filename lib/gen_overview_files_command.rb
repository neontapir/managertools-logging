require 'pathname'
require 'facets/string/titlecase'
require_relative 'employee'
require_relative 'employee_folder'
require_relative 'mt_data_formatter'
require_relative 'new_hire_command'
require_relative 'path_splitter'

extend MtDataFormatter
extend PathSplitter

# opts = Trollop.options do
#   banner 'Generate the files needed to create a team overview'
#   opt :force, 'generate even if file exists', default: false
# end
class GenerateOverviewFilesCommand

  def self.command(arguments)
    force = false
    if arguments.first == '--force'
      force = true
      arguments.shift
    end

    Dir.glob("#{EmployeeFolder.root}/*/*") do |folder|
      next unless Dir.exist? folder
      employee = Employee.find(folder)
      nhc_args = [employee.team, employee.first, employee.last]
      nhc_args.unshift('--force') if force
      NewHireCommand.command(nhc_args)
    end
  end
end
