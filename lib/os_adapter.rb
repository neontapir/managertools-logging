# frozen_string_literal: true

require 'os'

# Handle OS-specific calls
module OSAdapter
  def self.open
    if Settings.editor
      Settings.editor
    else
      OS.windows? ? 'cmd /c' : 'open'
    end
  end
end
