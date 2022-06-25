# frozen_string_literal: true

require './lib/diary_element'
require_relative 'diary_element_test_helper'

RSpec.describe DiaryElement do
  include DiaryElementTestHelper

  it 'creates an element with default values' do
    element = described_class.new(:location)
    proper?(element, :location, 'Location', DiaryElement::DEFAULT_VALUE)
  end

  it 'obtains the specified values' do
    allow(Settings.console).to receive(:ask).and_return('plough')
    element = described_class.new(:xyzzy)
    proper?(element, :xyzzy, 'Xyzzy', DiaryElement::DEFAULT_VALUE)
    expect(element.obtain).to eq 'plough'
  end

  it 'creates an element with specified values' do
    element = described_class.new(:actions, 'Actions to take', default: 'No actions')
    proper?(element, :actions, 'Actions to take', 'No actions')
  end

  context 'when label has special characters' do
    it 'raises an error' do
      expect { described_class.new(:question, 'Questions?', default: 'No questions') }.to raise_error ArgumentError
    end
  end

  context 'when prompt is different than label' do
    it 'shows the prompt, not the label' do
      allow(Settings.console).to receive(:ask).with('Prompt me: ').and_return('plough')
      element = described_class.new(:prompted, 'Label me', prompt: 'Prompt me', default: 'xyzzy')
      expect(element.obtain).to eq 'plough'
    end
  end

  context 'when prompt is nil' do
    it 'uses default' do
      expect(Settings.console).not_to receive(:ask)
      element = described_class.new(:unprompted, 'Do not prompt', default: 'xyzzy', prompt: nil)
      expect(element.obtain).to eq 'xyzzy'
    end
  end

  context 'when determining equality' do
    subject(:element) { described_class.new(:unprompted, 'Do not prompt', default: 'xyzzy', prompt: nil) }

    it 'implements equals' do
      equal = described_class.new(:unprompted, 'Do not prompt', default: 'xyzzy', prompt: nil)
      expect(element).to eq equal
    end

    it 'finds an element with a different key unequal' do
      different_key = described_class.new(:not_prompted, 'Do not prompt', default: 'xyzzy', prompt: nil)
      expect(element).not_to eq different_key
    end

    it 'finds an element with a different label unequal' do
      different_label = described_class.new(:unprompted, 'Fail to prompt', default: 'xyzzy', prompt: nil)
      expect(element).not_to eq different_label
    end

    it 'finds an element with a different value unequal' do
      different_value = described_class.new(:unprompted, 'Do not prompt', default: 'plover', prompt: nil)
      expect(element).not_to eq different_value
    end
  end
end
