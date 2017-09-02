# Base class for diary entries
# @!attribute [rw] record
#   @return [Hash] the entry's data dictionary of elements
class DiaryEntry
  attr_accessor :record

  # @!method initialize(**record)
  #   Create a new diary entry
  def initialize(**record)
    record[:datetime] = Time.now unless record.key? :datetime
    @record = record
  end

  # @!method get(name)
  #   Get the Ruby type of entry base on its name
  #   @param [String] name the name of the entry class
  #   @return [Class] the class referred to by the name
  def self.get(name)
    entry_type_name = name.to_s.tr('_', ' ').split(' ').map(&:capitalize).join
    Kernel.const_get("#{entry_type_name}Entry")
  end

  # @!method render(title, entry_type = self.class)
  #   Render the diary entry
  #   @param [String] title the header of the entry
  #   @param [Class] entry_type the Ruby class of the entry type
  #   @raise [ArgumentError] when entry_type is not a kind of DiaryEntry
  #   @return [String] an Asciidoc fragment suitable for appending to a log file
  def render(title, entry_type = self.class)
    raise NotImplementedError, 'DiaryElement#elements_array must be overriden' unless entry_type.instance_methods(false).include?(:elements_array)
    raise ArgumentError, "#{entry_type}#elements_array must return an enumerable" unless elements_array.is_a?(Enumerable)
    initial = "=== #{title} (#{format_date(@record.fetch(:datetime))})\n"
    populate(elements_array, initial)
  end

  # @abstract Gives the text shown at the beginning of an interactive session to provide the user context
  # @param [String] preamble the string to display
  def prompt(_preamble)
    raise NotImplementedError, 'DiaryElement#prompt must be overriden'
  end

  # @abstract Gives an array of DiaryElement objects that the user will be prompted to fill out
  # @return [Array] the elements to prompt on
  def elements_array
    raise NotImplementedError, 'DiaryElement#elements_array must be overriden'
  end

  # @abstract Gives the string representation of the class, written to the person's log file
  def to_s
    raise NotImplementedError, 'DiaryElement#to_s must be overriden'
  end

  private

  def populate(elements_array, initial)
    elements_array.inject(initial) do |output, entry|
      output << "#{entry.prompt}::\n  #{wrap(@record.fetch(entry.key, entry.default))}\n"
    end
  end
end
