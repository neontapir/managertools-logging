# frozen_string_literal: true

require 'fileutils'
require_relative 'employee'
require_relative 'employee_file'
require_relative 'observation_entry'

# Create a new entry for a person
class NewHireCommand
  def command(arguments)
    force = false
    if Array(arguments).first == '--force'
      force = true
      arguments.shift
    end

    team, first, last = arguments
    raise 'missing team argument' unless team
    raise 'missing first name argument' unless first
    raise 'missing last name argument' unless last
    employee = Employee.new(team: team, first: first, last: last)
    folder = EmployeeFolder.new employee
    folder.ensure_exists

    generate_overview_file_by(folder, force)
    generate_log_file_by(folder, force)
  end

  private

  def generate_overview_file_by(folder, force)
    overview_file = EmployeeFile.new folder, 'overview.adoc'
    print "\nReviewing #{overview_file}... "
    if !force && File.exist?(overview_file.path)
      print 'exists'
    else
      generate_overview_file folder, overview_file
    end
    print "\n"
  end

  # TODO: reduce duplication between this and log file generation
  def generate_overview_file(folder, overview_file)
    employee = folder.employee
    contents = <<~FILE_HEADER
      :imagesdir: #{folder.path}

      == #{employee}

      image::headshot.jpg[#{employee}, width="200", align="right", float="right"]

      Team: #{employee.team.capitalize}

    FILE_HEADER
    print 'created'
    File.open(overview_file.path, 'w') do |file|
      file.write(contents)
    end
  end

  def generate_log_file_by(folder, force)
    log_file = EmployeeFile.new folder, 'log.adoc'
    print "\Generating #{log_file}... "
    if !force && File.exist?(log_file.path)
      print 'exists'
    else
      log_file.ensure_exists
      contents = <<~CONTENTS
        === Biographical information

        === Employment information

        Hire Date:
        Grade level:
        ID:

      CONTENTS
      new_file_entry = ObservationEntry.new(content: 'File generated by new-hire command').render('File created')
      contents += new_file_entry
      File.open(log_file.path, 'w') { |f| f.write(contents) }
      print 'created'
    end
    print "\n"
  end
end
