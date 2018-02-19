# frozen_string_literal: true

require 'highline/import'
require 'settingslogic'

# Default file:
# defaults: &defaults
#   # root is set in lib/settings.rb
#   candidates_root: zzz_candidates
#   departed_root: zzz_departed # not used yet
#
# development:
#   <<: *defaults
#
# test:
#   <<: *defaults
#
# production:
#   <<: *defaults
#

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
