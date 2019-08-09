# frozen_string_literal: true

require 'fileutils'
require 'highline'

require_relative '../employee'
require_relative '../team'
require_relative '../settings'

# Implements team folder movement functionality
class MoveTeamCommand
  # @!method command(arguments, options)
  #   Move a person's data to a new folder
  def command(arguments, _ = nil)
    args = Array(arguments)
    target_team_spec = args.pop
    args.each do |employee_spec|
      process(employee_spec, target_team_spec)
    end
  end

  private

  def process(employee_spec, target_team_spec)
    employee = Employee.find employee_spec
    raise EmployeeNotFoundError, "No employee matching '#{employee_spec}' found, aborting" unless employee

    target_team = Team.find target_team_spec
    raise TeamNotFoundError, "No team matching '#{target_team_spec}' found, aborting" unless target_team

    if employee.team == target_team.path
      warn HighLine.color("Aborting, #{employee} is already in the expected folder", :red)
    else
      move(employee, target_team)
    end
  end

  def move(employee, target_team)
    puts "Moving #{employee} to team #{target_team}"
    move_entry = ObservationEntry.new(content: "Moving #{employee} to team #{target_team}")
    employee_file = employee.file
    employee_file.insert move_entry
    current_folder = File.dirname employee_file.path
    FileUtils.move(current_folder, "#{Settings.root}/#{target_team.path}/#{employee.canonical_name}")
  end
end
