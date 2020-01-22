require 'attr_extras'
require './lib/commands/mt_command'

RSpec.describe MtCommand do
  context 'when command is not defined' do
    subject(:inheritor) { Class.new(MtCommand).new }

    it 'raises an error' do
      expect { inheritor.command(nil, nil) }.to raise_error AttrExtras::MethodNotImplementedError
    end
  end
end