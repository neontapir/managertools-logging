require_relative 'employee_file'
require_relative 'feedback_entry'
require_relative 'o3_entry'

class LogFile
  attr_reader :o3_file

  def initialize(folder)
    @log_file = EmployeeFile.new folder, "log.adoc"
  end

  def append(entry)
    open(@log_file.path, 'a') { |f|
      f.puts entry
    }
  end
end
