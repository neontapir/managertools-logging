# frozen_string_literal: true

require 'fileutils'
require 'highline'
require 'tempfile'

require_relative '../employee'
require_relative '../team'
require_relative '../settings'

# Implements team folder movement functionality
class MoveTeamCommand
  # @!method command(arguments, options)
  #   Move a person's data to a new folder
  #   First argument is the team, then a list of people
  def command(arguments, _ = nil)
    args = Array(arguments).flatten
    target_team_spec = args.shift
    args.each do |employee_spec|
      process(target_team_spec, employee_spec)
    end
  end

  private

  def process(target_team_spec, employee_spec)
    employee = Employee.find employee_spec
    raise EmployeeNotFoundError, "No employee matching '#{employee_spec}' found, aborting" unless employee

    target_team = Team.find target_team_spec
    raise TeamNotFoundError, "No team matching '#{target_team_spec}' found, aborting" unless target_team

    if employee.team == target_team.path
      warn HighLine.color("Aborting, #{employee} is already in the expected folder", :red)
    else
      move(target_team, employee)
    end
  end

  def move(target_team, employee)
    update_overview_file(target_team, employee)
    move_folder(target_team, employee)
  end

  def move_folder(target_team, employee)
    puts "Moving #{employee} to team #{target_team}"
    move_entry = ObservationEntry.new(content: "Moving #{employee} to team #{target_team}")
    employee_file = employee.file
    employee_file.insert move_entry
    current_folder = File.dirname employee_file.path
    FileUtils.move(current_folder, target_team_path(target_team, employee))
  end

  def update_overview_file(target_team, employee)
    overview = employee.overview_location
    raise unless File.exist?(overview)

    temp_file = Tempfile.new(Settings.overview_filename)
    begin
      File.open(overview, 'r') do |file|
        file.each_line do |line|
          case line
          when /imagesdir/
            temp_file.puts ":imagesdir: #{target_team_path(target_team, employee)}"
          when /Team:/
            temp_file.puts "#{line.chomp}, #{target_team}"
          else
            temp_file.puts line
          end
        end
      end
      temp_file.close
      FileUtils.mv(temp_file.path, overview)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def target_team_path(target_team, employee)
    "#{Settings.root}/#{target_team.path}/#{employee.canonical_name}"
  end
end
