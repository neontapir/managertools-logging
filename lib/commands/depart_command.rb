# frozen_string_literal: true

require_relative '../settings'
require_relative 'move_team_command'

# Allows admin to move a person's folder to the departed section
class DepartCommand
  # @!method command(arguments, options)
  #   Mark a person departed by moving their data to the departed records folder
  def command(arguments, options = nil)
    args = Array(arguments).prepend(Settings.departed_root)
    ensure_departed_exists
    MoveTeamCommand.new.command(args, options)
  end

  def ensure_departed_exists
    departed_path = File.join(Settings.root,  Settings.departed_root)
    FileUtils.mkdir_p departed_path unless Dir.exist? departed_path
  end
end
