require 'configatron'
require 'fileutils'
require_relative 'employee'
require_relative 'employee_file'

# Create a new entry for a person
class NewHireCommand
  def generate_file(folder, overview_file)
    contents = <<EOF
:imagesdir: #{folder.path}

== #{folder.employee}

  image::headshot.jpg[#{folder.employee}, width="200", align="right", float="right"]

  Team: #{folder.employee.team.capitalize}

EOF
    print "generating\n"
    File.open(overview_file.path, 'w') do |f|
      f.write(contents)
    end
  end

  # opts = Trollop.options do
  #   banner 'Create a new entry for a person'
  #   opt :force, 'generate even if file exists'
  #   opt :team, 'team name (like avengers)', type: :string, required: true
  #   opt :first, 'person\'s first name (in quotes, like "Tony Stark")', type: :string
  #   opt :last, 'person\'s last name (in quotes, like "Tony Stark")', type: :string
  # end
  def command(arguments)
    force = false
    if arguments.first == '--force'
      force = true
      arguments.shift
    end

    team, first, last = arguments
    employee = Employee.new(team: team, first: first, last: last)
    folder = EmployeeFolder.new employee
    folder.ensure_exists

    overview_file = EmployeeFile.new folder, 'overview.adoc'
    print "\nReviewing #{overview_file}... "
    if !force && File.exist?(overview_file.path)
      print 'exists'
    else
      generate_file folder, overview_file
    end
    print "\n"

    log_file = EmployeeFile.new folder, 'log.adoc'
    log_file.ensure_exists
  end
end

