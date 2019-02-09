# frozen_string_literal: true

require 'os'

module OSAdapter
  def self.open
    if OS.windows?
      'cmd /c'
    else
      'open'
    end
  end
end