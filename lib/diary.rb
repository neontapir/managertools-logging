require_relative 'employee'
require_relative 'settings'
Dir["#{__dir__}/*_entry.rb"].each { |f| require_relative(f) }

# Base functionality for all entry types
module Diary
  # Returns true if a command line option requests a template instead of an interactive session
  def template?
    (@global_opts && @global_opts.template) || (@cmd_opts && @cmd_opts.template)
  end

  # Records a diary entry to the person's log file
  # @param [String] type The name of the template entry type
  # @param [String] person The name of the person
  def record_to_file(type, person)
    employee = Employee.get(person, type)
    entry = get_entry(type, employee)
    employee.file.append entry
  end

  # Gets a diary entry, whether as a template or as a filled-out entry
  # @param [String] type The name of the template entry type
  # @param [String] employee The name of the employee
  def get_entry(type, employee)
    data = template? ? {} : create_entry(type, employee.to_s)
    entry_type = DiaryEntry.get type
    entry_type.new data
  end

  # Creates a diary entry, getting responses from the user
  # @param [String] type The name of the template entry type
  # @param [String] header The entry header
  # @raise [ArgumentError] when type is not a kind of DiaryEntry
  def create_entry(type, header)
    entry_type = DiaryEntry.get type
    raise ArgumentError unless entry_type < DiaryEntry
    new_entry = entry_type.new
    Settings.console.say new_entry.send(:prompt, header)
    new_entry.send(:elements_array).each_with_object({}) do |item, memo|
      memo[item.key] = item.obtain
    end
  end
end
