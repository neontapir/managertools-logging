# frozen_string_literal: true

require 'attr_extras'

class MtCommand
  attr_implement :command, [:arguments, :options]
end