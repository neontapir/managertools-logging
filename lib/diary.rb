require 'highline/import'
require 'require_all'
require_rel '.'

# Base functionality for all entry types
module Diary
  def record_to_file(type, person)
    employee = Employee.get(person, type)
    entry = get_entry(type, employee)
    employee.file.append entry
  end

  def get_entry(type, employee)
    data = if (@global_opts && @global_opts.template) || (@cmd_opts && @cmd_opts.template)
             started_entry
           else
             create_entry type, employee.to_s
           end
    entry_type = DiaryEntry.get type
    entry_type.new data
  end

  def create_entry(type, name)
    entry_type = DiaryEntry.get type
    raise ArgumentError unless entry_type < DiaryEntry
    puts entry_type.send(:prompt, name)

    entry_type.send(:elements_array).each_with_object(started_entry) do |item, memo|
      memo[item.key] = item.obtain
    end
  end

  def started_entry
    hash = Hash.new('')
    hash[:datetime] = Time.now
    hash
  end
end
