# frozen_string_literal: true

require 'attr_extras'
require './lib/commands/mt_command'

RSpec.describe MtCommand do
  context 'when command is not defined' do
    subject(:inheritor) { Class.new(described_class).new }

    it 'raises an error' do
      expect { inheritor.command(nil, nil) }.to raise_error AttrExtras::MethodNotImplementedError
    end
  end
end
