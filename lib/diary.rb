require "highline/import"
require_relative 'employee'
require_relative 'employee_folder'
require_relative 'log_file'

module Diary
  def record_to_file(type, person)
    employee = get_employee person

    folder = EmployeeFolder.new employee
    folder.ensure_exists

    log_file = LogFile.new folder
    data = create_entry type, employee.to_s
    case type
    when :o3
      entry = O3Entry.new data
    when :feedback
      entry = FeedbackEntry.new data
    end
    log_file.append entry
  end

  def add_element(result, key, default = "none")
    result[key] = ask "#{key.to_s.capitalize}: " do |q|
      q.default = default
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
      [:polarity, :content].each do |symbol|
        add_element result, symbol
      end
    when :o3
      puts "For your 1:1 with #{employee}, enter the following:"
      [:location, :notes, :actions].each do |symbol|
        add_element result, symbol
      end
    else
      raise "You gave me #{type} -- I have no idea what to do with that."
    end

    result
  end
end
