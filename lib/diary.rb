require 'highline/import'
require 'require_all'
require_rel '.'

# Base functionality for all entry types
module Diary
  def record_to_file(type, person)
    employee = get_employee person, type
    entry = get_entry(type, employee)
    log_file = get_file employee
    log_file.ensure_exists
    log_file.append entry
  end

  def get_entry(type, employee)
    data = if (@global_opts && @global_opts.template) || (@cmd_opts && @cmd_opts.template)
             create_blank_entry type
           else
             create_entry type, employee.to_s
           end
    entry_type = get_entry_type(type)
    entry_type.new data
  end

  def get_entry_type(name)
    entry_type_name = name.to_s.tr('_', ' ').split(' ').map(&:capitalize).join
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

  def add_element(result, key, default = 'none')
    result[key] = ask "#{key.to_s.capitalize}: " do |q|
      q.default = default
    end
  end

  def create_spec(type)
    result = {}
    result[:team] = EmployeeFolder.candidates_root if type.to_sym == :interview
    [:team, :first, :last].each do |symbol|
      result[symbol] ||= ask "#{symbol.to_s.capitalize}: "
    end
    result
  end

  def get_employee(person, type = :generic)
    employee_spec = Employee.find person
    employee = if employee_spec.nil?
                 Employee.new(create_spec(type))
               else
                 employee_spec
               end
    employee
  end

  def get_team(team)
    team_spec = Team.find team
    die "No such team #{team} found" if team_spec.nil?
    team_spec
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
      result[item] = ''
    end
    result
  end

  def create_blank_hash
    { datetime: Time.now }
  end

  def get_entry_elements(type)
    entry_type = get_entry_type type
    entry_type.send(:elements_array)
  end
end
