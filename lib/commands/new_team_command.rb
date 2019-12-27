# frozen_string_literal: true

require_relative '../team_folder'
require_relative '../team'

# Create a new entry for a team. 
# NOTE: Strictly speaking, this command isn't necessary. The new hire command will create the team folder if it doesn't
# exist. It exists for parity with the new hire and new project commands.
class NewTeamCommand
  # command(arguments, options)
  #   Create the folder for a team
  def command(arguments, options = nil)
    # force = (options&.force == true)

    team_name = Array(arguments).first
    raise 'missing team argument' unless team_name

    project = Team.new(team: team_name)
    folder = TeamFolder.new project
    folder.ensure_exists

    print "\nCreated team #{team_name}... "
  end
end
