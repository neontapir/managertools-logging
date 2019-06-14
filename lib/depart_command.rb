# frozen_string_literal: true

require_relative 'move_team_command'
require_relative 'settings'

# Mark a person departed by moving their data to the departed records folder
class DepartCommand
  def command(arguments)
    arguments << Settings.departed_root
    MoveTeamCommand.new.command(arguments)
  end
end
