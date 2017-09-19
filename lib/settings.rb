# frozen_string_literal: true

require 'highline/import'
require 'settingslogic'

# Application-wide settings
class Settings < Settingslogic
  def self.root
    'data'
  end

  def self.console
    @console ||= HighLine.new(STDIN, STDOUT)
    @console
  end

  def self.set_console(input = STDIN, output = STDOUT)
    @console = HighLine.new(input, output)
  end

  source "#{Settings.root}/config.yml"
  namespace 'production' # Rails.env
end
