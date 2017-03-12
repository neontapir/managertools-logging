require_relative 'employee_file'

# Plumbing for log files
class LogFile
  include MtFile
  attr_reader :o3_file

  def initialize(folder)
    @log_file = EmployeeFile.new folder, 'log.adoc'
  end

  def append(entry)
    open(@log_file.path, 'a') do |f|
      f.puts "\n" unless entry.to_s[0, 1] == "\n"
      f.puts entry
    end
  end

  def path
    @log_file.path
  end
end
