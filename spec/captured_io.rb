# frozen_string_literal: true

require 'stringio'
require_relative 'settings_helper'

# Boilerplate for captured I/O
module CapturedIO
  include SettingsHelper

  def with_captured(input)
    input.rewind
    output = StringIO.new
    Settings.set_console(input, output)
    yield output
    Settings.set_console(STDIN, STDOUT)
  end
end
