require 'stringio'
require_relative 'settings_helper'

include SettingsHelper

# Boilerplate for captured I/O
module CapturedIO
  def with_captured(input)
    input.rewind
    output = StringIO.new
    Settings.set_console(input, output)
    yield output
    Settings.set_console(STDIN, STDOUT)
  end

  module_function
end
