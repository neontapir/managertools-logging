# frozen_string_literal: true

require_relative 'diary'

# Create a new RecordDiaryEntryCommand object
class RecordDiaryEntryCommand
  include Diary

  # these parameters are used by the diary module commands
  def initialize(global_options = {}, command_options = {})
    @global_opts ||= global_options
    @cmd_opts ||= command_options
  end

  def command(subcommand, arguments)
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
