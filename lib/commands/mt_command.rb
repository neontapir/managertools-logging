# frozen_string_literal: true

require 'attr_extras'

# For reporting employee searches with no results
class EmployeeNotFoundError < StandardError
end

# For reporting entity searches with no results
class EntityNotFoundError < StandardError
end

# a base class that enforces implementation of a command method
class MtCommand
  attr_implement :command, [:arguments, :options]
end
