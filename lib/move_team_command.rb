# frozen_string_literal: true

require 'fileutils'

require_relative 'employee'
require_relative 'team'
require_relative 'settings'

# Move a person's data to a new folder
class MoveTeamCommand
  def command(arguments)
    employee_spec, target_team_spec = Array(arguments)
    employee = Employee.find employee_spec
    raise ArgumentError, "No employee matching '#{employee_spec}' found, aborting" unless employee

    target_team = Team.find target_team_spec
    raise ArgumentError, "No team matching '#{target_team_spec}' found, aborting" unless target_team

    if employee.team == target_team.path
      puts "#{employee} is already in the expected folder"
    else
      move(employee, target_team)
    end
  end

  def move(employee, target_team)
    puts "Moving #{employee} to team #{target_team}"
    move_entry = ObservationEntry.new(content: "Moving #{employee} to team #{target_team}")
    employee.file.insert move_entry
    current_folder = File.dirname employee.file.path
    FileUtils.move(current_folder, "#{Settings.root}/#{target_team.path}/#{employee.canonical_name}")
  end
end
