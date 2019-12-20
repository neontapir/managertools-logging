# frozen_string_literal: true

require 'fileutils'
require 'ostruct'
require 'thor'
require_relative '../employee'
require_relative '../entity_file'
require_relative '../file_writer'
require_relative '../entries/observation_entry'
require_relative '../settings'

# Create a new entry for a person
class NewHireCommand
  include FileWriter

  # command(arguments, options)
  #   Create new overview and load files for a person
  def command(arguments, options = nil)
    force = (options&.force == true)

    team, first, last = Array(arguments)
    raise 'missing team argument' unless team
    raise 'missing first name argument' unless first
    raise 'missing last name argument' unless last

    employee = Employee.new(team: team, first: first, last: last)
    folder = EmployeeFolder.new employee
    folder.ensure_exists

    nhc_parameters = OpenStruct.new(folder: folder, force: force)
    generate_overview_file_by(nhc_parameters)
    generate_log_file_by(nhc_parameters)
    employee
  end

  private

  # template method that uses the parameteres to genereate the given file
  def generate_file_by(nhc_parameters, filename)
    content_file = EntityFile.new nhc_parameters.folder, filename
    print "\nReviewing #{content_file}... "
    if !nhc_parameters.force && File.exist?(content_file.path)
      print 'exists'
    else
      yield(content_file)
    end
    print "\n"
  end

  # creates a new overview file
  def generate_overview_file_by(nhc_parameters)
    generate_file_by(nhc_parameters, Settings.overview_filename) do |content_file|
      create_overview_file nhc_parameters.folder, content_file
    end
  end

  # creates a new log file
  def generate_log_file_by(nhc_parameters)
    generate_file_by(nhc_parameters, Settings.log_filename) do |content_file|
      create_log_file content_file
    end
  end

  # creates a new overview file from a hardcoded template
  def create_overview_file(folder, overview_file)
    employee = folder.employee
    contents = <<~OVERVIEW
      :imagesdir: #{folder.path}

      == #{employee}

      image::#{employee.canonical_name}.jpg[#{employee}, width="200", align="right", float="right"]

      Team: #{employee.team}

    OVERVIEW
    write_file(overview_file.path, contents)
    print 'created'
  end

  # creates a new log file from a hardcoded template
  def create_log_file(log_file)
    log_file.ensure_exists
    contents = <<~CONTENTS
      #{DiaryEntry::ENTRY_HEADER_MARKER} Biographical information

      #{@biography}

      #{DiaryEntry::ENTRY_HEADER_MARKER} Employment information

      Hire Date: #{@hire_date}
      Grade level: #{@grade_level}

    CONTENTS
    new_file_entry = ObservationEntry.new(content: 'File generated by new-hire command').render('File created')
    contents += new_file_entry
    write_file(log_file.path, contents)
    print 'created'
  end
end
