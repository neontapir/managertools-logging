require_relative 'employee_file'

# Plumbing for log files
class LogFile
  include MtFile
  attr_reader :o3_file

  def initialize(folder)
    @log_file = EmployeeFile.new folder, 'log.adoc'
  end

  def append(entry)
    ensure_exists
    open(@log_file.path, 'a') do |file|
      file.puts "\n" unless entry.to_s[0, 1] == "\n" # ensure leading CR for Asciidoc
      file.puts entry
    end
  end

  def path
    @log_file.path
  end
end
