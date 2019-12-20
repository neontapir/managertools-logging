# frozen_string_literal: true

require 'os'

# Handle OS-specific calls
module OSAdapter
  # command to open a file, which is OS-dependent
  def self.open_command
    Settings.editor || OS.open_file_command
  end
end
