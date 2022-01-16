# frozen_string_literal: true

require_relative '../diary'
require_relative '../employee'
require_relative 'mt_command'
require_relative '../string_extensions'

# Implements diary recording functionality
class RecordDiaryEntryCommand < MtCommand
  include Diary
  using StringExtensions

  # command(arguments, options)
  #   Record a new diary entry in the person's file
  def command(subcommand, arguments, _options = nil)
    raise 'missing person name argument' unless arguments.first

    log_message(to_entities(arguments), subcommand.to_sym)
  end

  private

  # takes a list of entity specs and converts it into entity objects
  def to_entities(entity_specs)
    entity_specs.map do |item|
      entity = Employee.find(item) || Project.find(item)
      raise EntityNotFoundError, "unable to find employee or project '#{item}'" unless entity

      entity
    end.uniq
  end

  # logs the same message to each entity's file
  def log_message(group, entry_type)
    entry = nil
    group.each do |entity|
      entry ||= get_entry(
        entry_type,
        group.join(','),
        applies_to: group
          .map { |m| m.to_s.to_name }
          .join(', '),
      )
      entity.file.insert entry
    end
  end
end
