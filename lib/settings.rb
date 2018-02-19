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

  # unless File.exist? "#{Settings.root}/config.yml"
  #   puts 'Write default configuration file'
  #   contents = <<~CONTENTS
  #     defaults: &defaults
  #       # root is set in lib/settings.rb
  #       candidates_root: zzz_candidates
  #       departed_root: zzz_departed # not used yet

  #     production:
  #       <<: *defaults
  #   CONTENTS
  #   File.open("#{Settings.root}/config.yml", 'w') { |f| f.write(contents) } 
  # end
  source "#{Settings.root}/config.yml"
  namespace 'production' # Rails.env
end
