require "highline/import"
require_relative 'employee'
require_relative 'employee_folder'
require_relative 'feedback_entry'
require_relative 'log_file'
require_relative 'o3_entry'
require_relative 'observation_entry'

module Diary
  def record_to_file(type, person)
    employee = get_employee person

    folder = EmployeeFolder.new employee
    folder.ensure_exists

    log_file = LogFile.new folder
    data = create_entry type, employee.to_s
    entry_type = Kernel.const_get("#{type.to_s.capitalize}Entry")
    #puts "entry type: #{entry_type}"
    entry = entry_type.new data
    log_file.append entry
  end

  def add_element(result, key, default = "none")
    result[key] = ask "#{key.to_s.capitalize}: " do |q|
      q.default = default
    end
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

  def get_employee(person)
    employee_spec = Employee.find person
    if (employee_spec.nil?)
      result = Hash.new
      [:team, :first, :last].each do |symbol|
        result[symbol] = ask "#{symbol.to_s.capitalize}: "
      end
      employee = Employee.new result
    else
      employee = employee_spec
    end
    employee
  end

  def create_entry(type, employee)
    result = Hash.new
    result[:datetime] = Time.now

    case type
    when :feedback
      puts "With feedback for #{employee}, enter the following:"
      add_elements(result, [[:polarity, "positive"], :content])
    when :o3
      puts "For your 1:1 with #{employee}, enter the following:"
      add_elements(result, [:location, :notes, :actions])
    when :observation
      puts "Enter your observation for #{employee}:"
      add_elements(result, [:content])
    else
      raise "You gave me #{type} -- I have no idea what to do with that."
    end

    result
  end
end
