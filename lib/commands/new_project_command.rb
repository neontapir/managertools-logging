# frozen_string_literal: true

require 'fileutils'
require 'ostruct'
require 'thor'
require_relative '../entity_file'
require_relative '../file_writer'
require_relative 'mt_command'
require_relative '../entries/observation_entry'
require_relative '../project_folder'
require_relative '../project'
require_relative '../settings'

# Create a new entry for a person
class NewProjectCommand < MtCommand
  include FileWriter

  # colletion of valid parameters
  NpcParameters = Struct.new(:folder, :force, :summary)

  # command(arguments, options)
  #   Create new overview and load files for a person
  def command(arguments, options = nil)
    force = (options&.force == true)

    project_name = Array(arguments).first
    raise 'missing project argument' unless project_name

    project = Project.new(project: project_name)
    folder = ProjectFolder.new project
    folder.ensure_exists

    summary = ask 'Project summary? '
    # TODO: This method of setting a default doesn't work in the unit tests, yet we do this elsewhere. Investigate.
    # summary = Settings.console.ask 'Project summary?' do |answer|
    #   answer.default = 'undefined'
    # end

    npc_parameters = NpcParameters.new(folder, force, summary)
    generate_log_file(npc_parameters)
  end

  private

  # creates a new log file
  def generate_log_file(npc_parameters)
    content_file = EntityFile.new(npc_parameters.folder, Settings.log_filename)
    print "\nReviewing #{content_file}... "
    if !npc_parameters.force && File.exist?(content_file.path)
      print 'exists'
    else
      create_log_file(npc_parameters, content_file)
    end
    print "\n"
  end

  # creates a new log file from a template
  def create_log_file(npc_parameters, log_file)
    log_file.ensure_exists
    contents = <<~CONTENTS
      === Project information

      #{npc_parameters.summary || 'undefined'}

    CONTENTS
    new_file_entry = ObservationEntry.new(content: 'File generated by new-project command').render('File created')
    contents += new_file_entry
    write_file(log_file.path, contents)
    print 'created'
  end
end
