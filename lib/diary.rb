# frozen_string_literal: true

require_relative 'employee'
require_relative 'settings'
Dir["#{__dir__}/*_entry.rb"].each { |f| require_relative(f) }

# Base functionality for all entry types. Extends the diary entry with I/O.
module Diary
  # @!method template?
  #   Returns true if a command line option requests a template instead of an interactive session
  #   This is used by the MT top-level script, but not in unit-tested code
  def template?
    @command_opts&.template
  end

  # @!method record_to_file(type, person)
  #   Records a diary entry to the person's log file
  #   @param [String] type The name of the template entry type
  #   @param [String] person The name of the person
  def record_to_file(type, person)
    employee = Employee.get(person, type)
    entry = get_entry(type, employee)
    employee.file.insert entry
  end

  # @!method get_entry(type, employee, initial_value)
  #   Gets a diary entry, whether as a template or as a filled-out entry
  #   @param [String] type The name of the template entry type
  #   @param [String] employee The name of the employee
  #   @param [Hash] initial_record The initial hash of entry values
  def get_entry(type, employee, initial_record = {})
    data = template? ? {} : create_entry(type, employee.to_s, initial_record)
    # HACK: For Multiple member, I want to show the injected value in the
    #   template. That creates a chicken and the egg problem. During
    #   create_entry, the contents of initial_value aren't retained.
    #   This kludge forces them back in. Fix this.
    data.merge! initial_record
    entry_type = DiaryEntry.get type
    entry_type.new data
  end

  # @!method create_entry(type, header, initial_value)
  #   Creates a diary entry, getting responses from the user
  #   @param [String] type The name of the template entry type
  #   @param [String] header The entry header
  #   @param [Hash] initial_record The initial hash of values
  #   @raise [ArgumentError] when type is not a kind of DiaryEntry
  def create_entry(type, header, initial_record)
    entry_type = DiaryEntry.get type
    raise ArgumentError unless entry_type < DiaryEntry

    new_entry = entry_type.new initial_record
    new_entry.populate(header)
  end
end
