# frozen_string_literal: true

require 'fileutils'
require 'highline'
require 'tempfile'

require_relative '../employee'
require_relative '../team'
require_relative '../settings'

# Implements team folder movement functionality
class MoveTeamCommand
  # command(arguments, options)
  #   Move a person's data to a new folder
  #   First argument is the team, then a list of people
  def command(arguments, _ = nil)
    args = Array(arguments).flatten
    target_team_spec = args.shift
    args.each do |employee_spec|
      move_team(target_team_spec, employee_spec)
    end
  end

  private

  # Checks preconditions for move, then executes the move
  def move_team(target_team_spec, employee_spec)
    employee, target_team = parse_input(target_team_spec, employee_spec)

    if employee.team == target_team.path
      warn HighLine.color("Aborting, #{employee} is already in the expected folder", :red)
    else
      move(target_team, employee)
    end
  end

  # parse input to get entities to act against
  def parse_input(target_team_spec, employee_spec)
    target_team = Team.find target_team_spec
    unless target_team
      warn HighLine.color("No team matching '#{target_team_spec}' found, will try swapping parameters", :yellow)
      (employee_spec, target_team_spec) = target_team_spec, employee_spec
      target_team = Team.find target_team_spec
    end
    raise TeamNotFoundError, "No team matching '#{target_team_spec}' found, aborting" unless target_team

    employee = Employee.find employee_spec
    raise EmployeeNotFoundError, "No employee matching '#{employee_spec}' found, aborting" unless employee

    [employee, target_team]
  end

  # Moves the employee's files to the target team's folder
  def move(target_team, employee)
    update_overview_file(target_team, employee)
    move_folder(target_team, employee)
  end

  # Move the employee's files
  def move_folder(target_team, employee)
    destination = destination_label(target_team)
    puts "Moving #{employee} to #{destination}"
    move_entry = ObservationEntry.new(content: "Moving #{employee} to #{destination}")
    employee_file = employee.file
    employee_file.insert move_entry
    current_folder = File.dirname employee_file.path
    FileUtils.move(current_folder, target_team_path(target_team, employee))
  end

  # compose desitnation for console message
  def destination_label(target_team)
    %w[candidates departed project].each do |word|
      return "#{word} folder" if target_team.path.match?(/#{Settings.send("#{word}_root")}/)
    end
    "team #{target_team}"
  end

  # only add team to person's overview file if it's a regular team
  # NOTE: relies on destination_team implementation
  def add_to_team_list?(target_team)
    destination_label(target_team).start_with? 'team '
  end

  # Add the new team to the person's overview file
  def update_overview_file(target_team, employee)
    overview = employee.overview_location
    raise unless File.exist?(overview)

    temp_file = Tempfile.new(Settings.overview_filename)
    begin
      File.open(overview, 'r') do |file|
        file.each_line { |line| temp_file.puts updated_line(line, target_team, employee) }
      end
      temp_file.close
      FileUtils.mv(temp_file.path, overview)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def updated_line(line, target_team, employee)
    case line
    when /imagesdir/
      ":imagesdir: #{target_team_path(target_team, employee)}"
    when /Team:/
      add_to_team_list?(target_team) ? "#{line.chomp}, #{target_team}" : line
    else line
    end
  end

  # Build the destination path for the move
  def target_team_path(target_team, employee)
    File.join(Settings.root, target_team.path, employee.canonical_name)
  end
end
