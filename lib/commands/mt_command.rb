# frozen_string_literal: true

require 'attr_extras'

# a base class that enforces implementation of a command method
class MtCommand
  attr_implement :command, [:arguments, :options]
end
