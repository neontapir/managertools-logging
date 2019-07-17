# frozen_string_literal: true

require 'os'

# Handle OS-specific calls
module OSAdapter
  def self.open_command
    Settings.editor || OS.open_file_command
  end
end
