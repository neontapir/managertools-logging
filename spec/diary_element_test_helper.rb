# frozen_string_literal: true

# Set expectations for a diary element
module DiaryElementTestHelper
  def proper?(element, key, prompt, default)
    expect(element.key).to be(key)
    expect(element.prompt).to eq prompt
    element_default = element.default
    if (element_default.is_a? Time)
      expect(element_default).to be_within(2).of(default)
    else
      expect(element_default).to eq default
    end
  end
end