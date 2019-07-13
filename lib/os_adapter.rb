# frozen_string_literal: true

require 'os'

# Handle OS-specific calls
module OSAdapter
  def self.open_command
    editor = Settings.editor
    editor ||= OS.windows? ? 'cmd /c' : 'open'
    editor
  end
end
