require 'highline/import'

# Base class for diary entries
# @attr_reader [Hash] record the entry's data dictionary of elements
class DiaryEntry
  attr_accessor :record

  # Create a new diary entry
  def initialize(**record)
    @record = record
  end

  # Get the Ruby type of entry base on its name
  # @param [String] name the name of the entry class
  def self.get(name)
    entry_type_name = name.to_s.tr('_', ' ').split(' ').map(&:capitalize).join
    Kernel.const_get("#{entry_type_name}Entry")
  end

  # Render the diary entry
  # @param [String] title the header of the entry
  # @param [Class] entry_type the Ruby class of the entry type
  # @raise [ArgumentError] when entry_type is not a kind of DiaryEntry
  def render(title, entry_type = self.class)
    raise ArgumentError, "#{entry_type} is not a DiaryEntry" unless entry_type.respond_to?(:elements_array)
    initial = "=== #{title} (#{format_date(@record.fetch(:datetime))})\n"
    entry_type.elements_array.inject(initial) do |output, entry|
      output << "#{entry.prompt}::\n  #{wrap(@record.fetch(entry.key, entry.default))}\n"
    end
  end
end
