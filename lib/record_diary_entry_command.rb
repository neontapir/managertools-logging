# frozen_string_literal: true

require_relative 'diary'

class RecordDiaryEntryCommand
  include Diary

  def command(subcommand, arguments)
    entry_type = subcommand.to_sym
    person = arguments.first
    record_to_file entry_type, person
  end
end