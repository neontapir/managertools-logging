# frozen_string_literal: true

require 'attr_extras'

# Base error class for all Manager Tools errors
class ManagerToolsError < StandardError
end

# Base error class for all not found errors
class NotFoundError < ManagerToolsError
  def initialize(entity_type, identifier)
    super("#{entity_type.to_s.capitalize} '#{identifier}' not found")
  end
end

# For reporting employee searches with no results
class EmployeeNotFoundError < NotFoundError
  def initialize(identifier)
    super(:employee, identifier)
  end
end

# For reporting team searches with no results
class TeamNotFoundError < NotFoundError
  def initialize(identifier)
    super(:team, identifier)
  end
end

# For reporting project searches with no results
class ProjectNotFoundError < NotFoundError
  def initialize(identifier)
    super(:project, identifier)
  end
end

# For reporting general entity searches with no results
class EntityNotFoundError < NotFoundError
  def initialize(identifier)
    super(:entity, identifier)
  end
end

# For reporting missing required arguments
class MissingArgumentError < ManagerToolsError
  def initialize(argument_name)
    super("Missing required argument: #{argument_name}")
  end
end

# a base class that enforces implementation of a command method
class MtCommand
  attr_implement :command, [:arguments, :options]
end
