# frozen_string_literal: true

require 'chronic'
require_relative '../mt_data_formatter'

# Base class for diary entries
# @!attribute [r] record
#   @return [Hash] the entry's data dictionary of elements
class DiaryEntry
  attr_reader :record
  include MtDataFormatter

  # @!method initialize(**record)
  #   Create a new diary entry
  def initialize(**record)
    record[:datetime] = Time.now.to_s unless record.key? :datetime
    @record = record
  end

  # @!method get(name)
  #   Get the Ruby type of entry base on its name
  #   @param [String] name the name of the entry class
  #   @return [Class] the class referred to by the name
  def self.get(name)
    entry_type_name = name.to_s.tr('_-', '  ').split(' ').map(&:capitalize).join
    Kernel.const_get "#{entry_type_name}Entry"
  end

  # @!method render(title, entry_type = self.class)
  #   Render the diary entry
  #   @param [String] title the header of the entry
  #   @param [Class] entry_type the Ruby class of the entry type
  #   @raise [ArgumentError] when entry_type is not a kind of DiaryEntry
  #   @return [String] an Asciidoc fragment suitable for appending to a log file
  def render(title, entry_type = self.class)
    raise NotImplementedError, 'DiaryEntry#elements must be overriden' unless entry_type.instance_methods(false).include?(:elements)
    raise ArgumentError, "#{entry_type}#elements must return an enumerable" unless elements.is_a?(Enumerable)
    raise ArgumentError, "record[:datetime] must be a Time, not a #{date.class}" unless date.is_a?(Time)

    initial = "=== #{title} (#{format_date(date)})\n"
    elements.reject { |element| header_items.include? element.key }.inject(initial) do |output, entry| # rubocop:disable CollectionMethods
      output + "#{entry.label}::\n  #{wrap(@record.fetch(entry.key, entry.default))}\n"
    end
  end

  # @abstract Gives the text shown at the beginning of an interactive session to provide the user context
  #   @param [String] preamble the string to display
  def prompt(_preamble)
    raise NotImplementedError, 'DiaryEntry#prompt must be overriden'
  end

  # @abstract Gives an array of DiaryElement objects that the user will be prompted to fill out
  #   @return [Array] the elements to prompt on
  def elements
    raise NotImplementedError, 'DiaryEntry#elements must be overriden'
  end

  # Augments the array of DiaryElement objects with the list of affected people for user confirmation
  #   @param [Array] result the elements to prompt on
  #   @return [Array] the elements to prompt on, including applies_to
  def with_applies_to(result)
    return result unless record.key?(:applies_to)

    applies_to = record.fetch(:applies_to)
    result.insert(1, DiaryElement.new(:applies_to, 'Applies to', default: applies_to)) if applies_to.include?(',')
    result
  end

  # fill in the template with the given record entries
  #   @param [String] header_prompt the banner to display before gathering template values
  def populate(header_prompt)
    Settings.console.say prompt(header_prompt)
    data = elements.each_with_object({}) do |item, entry_record|
      entry_record[item.key] = item.obtain
    end
    data = post_create(data)
    data
  end

  # a hook to modify data after prompting for responses,
  #   useful for populating derived values, see PtoEntry's duration for example
  #   @param data [Hash] the data gathered for this entry
  #   @return [Hash] the modified data
  def post_create(data)
    data
  end

  # @abstract Gives the effective date of the entry
  #   @return [Time] the date
  def date
    Time.parse record.fetch(:datetime).to_s
  end

  # @abstract Gives the string representation of the class, written to the person's log file
  def to_s
    raise NotImplementedError, 'DiaryEntry#to_s must be overriden'
  end

  private

  # items in the header_items array will not be included in the body of the entry, just the header
  def header_items
    [:datetime]
  end
end
