require_relative 'employee_file'

# Plumbing for log files
class LogFile
  include MtFile

  # Create a new log file
  # @param [EmployeeFolder] folder the containing folder
  def initialize(folder)
    @log_file = EmployeeFile.new folder, 'log.adoc'
  end

  # Append a DiaryEntry to the file
  # @param [DiaryEntry] entry the entry to append
  def append(entry)
    ensure_exists
    open(@log_file.path, 'a') do |file|
      file.puts "\n" unless entry.to_s[0, 1] == "\n" # ensure leading CR for Asciidoc
      file.puts entry
    end
  end

  # Get the file system path to the file
  def path
    @log_file.path
  end
end
