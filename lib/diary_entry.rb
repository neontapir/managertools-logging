class DiaryEntry
  attr_accessor :record

  def initialize(**params)
    @record = params
  end

  def render(title, entry_type = self.class)
    initial = "=== #{title} (#{format_date(@record[:datetime])})\n"
    entry_type.elements_array.inject(initial) do |output, p|
      output << "#{p.prompt}::\n  #{wrap(@record[p.key] || p.default)}\n"
    end
  end
end
