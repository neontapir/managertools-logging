# frozen_string_literal: true

require 'os'

# Handle OS-specific calls
module OSAdapter
  def self.open
    OS.windows? ? 'cmd /c' : 'open'
  end
end
