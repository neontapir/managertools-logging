# frozen_string_literal: true

require_relative 'diary'

class RecordDiaryEntryCommand
  include Diary

  def initialize(global_options, command_options)
    @global_opts ||= global_options
    @cmd_opts ||= command_options
  end

  def command(subcommand, arguments)
    entry_type = subcommand.to_sym
    person = arguments.first
    record_to_file entry_type, person
  end
end