# frozen_string_literal: true

require_relative '../settings'
require_relative 'move_team_command'

# Allows admin to move a person's folder to the departed section
class DepartCommand
  # @!method command(arguments, options)
  #   Mark a person departed by moving their data to the departed records folder
  def command(arguments, options = nil)
    args = Array(arguments).prepend(Settings.departed_root)
    MoveTeamCommand.new.command(args, options)
  end
end
