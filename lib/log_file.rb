require_relative 'employee_file'

class LogFile
  include MtFile
  attr_reader :o3_file

  def initialize(folder)
    @log_file = EmployeeFile.new folder, "log.adoc"
  end

  def append(entry)
    open(@log_file.path, 'a') { |f|
      f.puts "\n" unless entry.to_s[0,1] == "\n"
      f.puts entry
    }
  end

  def path
    @log_file.path
  end
end
