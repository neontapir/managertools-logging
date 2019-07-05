# frozen_string_literal: true

require_relative 'diary'

# Implements diary recording functionality
class RecordDiaryEntryCommand
  include Diary

  # @!method command(arguments, options)
  #   Record a new diary entry in the person's file
  def command(subcommand, arguments, options = nil)
    @command_opts ||= options
    entry_type = subcommand.to_sym
    raise 'missing person name argument' unless arguments.first

    members = arguments.map do |person|
      employee = Employee.find(person)
      raise "unable to find employee '#{person}'" unless employee

      employee
    end

    entry = nil
    members.each do |employee|
      entry ||= get_entry(entry_type, members.join(','), applies_to: members.map(&:to_s).join(', '))
      employee.file.insert entry
    end
  end
end
