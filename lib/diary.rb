# frozen_string_literal: true

require_relative 'employee'
require_relative 'settings'
Dir["#{__dir__}/entries/*_entry.rb"].each { |f| require_relative(f) }

# Base functionality for all entry types. Extends the diary entry with I/O.
module Diary
  # template?
  #   Returns true if a command line option requests a template instead of an interactive session
  #   This is used by the MT top-level script, but not in unit-tested code
  def template?
    @command_opts&.template
  end

  # record_to_file(type, person)
  #   Records a diary entry to the person's log file
  #   @param [String] type The name of the template entry type
  #   @param [String] person The name of the person
  def record_to_file(type, person)
    employee = Employee.get(person, type)
    entry = get_entry(type, employee)
    employee.file.insert entry
  end

  # get_entry(type, header, initial_record)
  #   Gets a diary entry, whether as a template or as a filled-out entry
  #   @param [String] type The name of the template entry type
  #   @param [String] header The header, often the name of the employee
  #   @param [Hash] initial_record The initial hash of entry values
  #   @raise [ArgumentError] when type is not a kind of DiaryEntry
  def get_entry(type, header, initial_record = {})
    entry_type = DiaryEntry.get type
    raise ArgumentError unless entry_type < DiaryEntry

    user_input = template? ? {} : create_entry(entry_type, header.to_s, initial_record)
    data = initial_record.merge(user_input)

    entry_type.new(**data)
  end

  private

  # create_entry(entry_type, header, initial_record)
  #   Creates a diary entry, getting responses from the user
  #   @param [Class] entry_type The class of the template entry
  #   @param [String] header The entry header
  #   @param [Hash] initial_record The initial hash of values
  def create_entry(entry_type, header, initial_record)
    new_entry = entry_type.new(**initial_record)
    new_entry.populate(header, initial_record)
  end
end
