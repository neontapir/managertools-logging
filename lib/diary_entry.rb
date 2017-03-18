require 'highline/import'

# Base class for diary entries
class DiaryEntry
  attr_accessor :record

  def initialize(**params)
    @record = params
  end

  def self.get(name)
    entry_type_name = name.to_s.tr('_', ' ').split(' ').map(&:capitalize).join
    Kernel.const_get("#{entry_type_name}Entry")
  end

  def render(title, entry_type = self.class)
    raise ArgumentError, "#{entry_type} is not a DiaryEntry" unless entry_type.respond_to?(:elements_array)
    initial = "=== #{title} (#{format_date(@record[:datetime])})\n"
    entry_type.elements_array.inject(initial) do |output, entry|
      output << "#{entry.prompt}::\n  #{wrap(@record[entry.key] || entry.default)}\n"
    end
  end
end
