# frozen_string_literal: true

require 'os'

# Handle OS-specific calls
module OSAdapter
  def self.open
    if OS.windows?
      'cmd /c'
    else
      'open'
    end
  end
end