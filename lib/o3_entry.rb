require_relative 'mt_data_formatter'

include MtDataFormatter

# Template for a one-on-one meeting
class O3Entry < DiaryEntry
  def self.prompt(name)
    "For your 1:1 with #{name}, enter the following:"
  end

  def self.elements_array
    [
      DiaryElement.new(:location, 'Location', 'unspecified'),
      DiaryElement.new(:notes),
      DiaryElement.new(:actions)
    ]
  end

  def to_s
    render('One-on-One')
  end
end
