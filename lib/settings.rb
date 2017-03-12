require 'settingslogic'

# Application-wide settings
class Settings < Settingslogic
  def self.root
    'data'
  end

  source "#{Settings.root}/config.yml"
  namespace 'production' # Rails.env
end
