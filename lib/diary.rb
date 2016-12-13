require "highline/import"
require_relative 'employee'
require_relative 'employee_folder'
require_relative 'feedback_entry'
require_relative 'interview_entry'
require_relative 'log_file'
require_relative 'o3_entry'
require_relative 'observation_entry'
require_relative 'team_meeting_entry'

module Diary
  def record_to_file(type, person)
    employee = get_employee person, type
    entry = get_entry(type, employee)
    log_file = get_file employee
    log_file.ensure_exists
    log_file.append entry
  end

  def get_entry(type, employee)
    if @global_opts.template or @cmd_opts.template
      data = create_blank_entry type
    else
      data = create_entry type, employee.to_s
    end
    entry_type = get_entry_type(type)
    entry = entry_type.new data
  end

  def get_entry_type(name)
    entry_type_name = name.to_s.tr('_',' ').split(' ').map(&:capitalize).join
    Kernel.const_get("#{entry_type_name}Entry")
  end

  def get_file_by_person(person)
    employee = get_employee person
    get_file employee
  end

  def get_file(employee)
    folder = EmployeeFolder.new employee
    folder.ensure_exists
    LogFile.new folder
  end

  def add_elements(result, elements)
    elements.each do |item|
      if item.kind_of? Array
        add_element result, item[0], item[1]
      else
        add_element result, item
      end
    end
  end

  def add_element(result, key, default = "none")
    result[key] = ask "#{key.to_s.capitalize}: " do |q|
      q.default = default
    end
  end

  def get_employee(person, type = :generic)
    employee_spec = Employee.find person
    if (employee_spec.nil?)
      result = Hash.new
      result[:team] = EmployeeFolder.candidates_root if type.to_sym == :interview
      [:team, :first, :last].each do |symbol|
          result[symbol] ||= ask "#{symbol.to_s.capitalize}: "
      end
      employee = Employee.new result
    else
      employee = employee_spec
    end
    employee
  end

  def get_team(team)
    team_spec = Team.find team
    if (team_spec.nil?)
      die "No such team #{team} found"
    else
      team = team_spec
    end
    team
  end

  def create_entry(type, name)
    result = create_blank_hash

    entry_type = get_entry_type type
    puts entry_type.send(:prompt, name)

    elements = get_entry_elements(type)
    add_elements(result, elements)

    result
  end

  def create_blank_entry(type)
    result = create_blank_hash
    elements = get_entry_elements(type)
    elements.each do |item|
      result[item] = ""
    end
    result
  end

  def create_blank_hash()
    result = Hash.new
    result[:datetime] = Time.now
    result
  end

  def get_entry_elements(type)
    entry_type = get_entry_type type
    entry_type.send(:get_elements_array)
  end
end
