# frozen_string_literal: true

# File writing utility methods
module FileWriter
  # Append an entry to a member's file
  def append_file(destination, contents)
    File.open(destination, 'a') do |file|
      file.puts contents
      file.puts "\n"
    end
  end

  # Make a file with the given contents, will overwrite existing content
  def write_file(destination, contents)
    File.open(destination, 'w') do |file|
      file.write contents
    end
  end
end
