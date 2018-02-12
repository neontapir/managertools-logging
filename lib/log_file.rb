# frozen_string_literal: true

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
    # open(@log_file.path, 'w') do |file|
    open(@log_file.path, 'a') do |file|
      # file.seek(-5, :END)
      # position = get_position(entry)
      file.write "\n" unless entry.to_s[0, 1] == "\n" # ensure leading CR for Asciidoc
      file.write entry
    end
  end

  # def get_position(entry)
  #   entry_date = Time.parse(entry.elements_array.find{ |e| e.key == :datetime }.default)

  #   datelines = {}
  #   File.foreach(@log_file.path).with_index do |line, line_num|
  #     matches = /^===.*\((.*)\)/.match(line)
  #     unless matches.to_a.empty?
  #       line_date = Time.parse(matches[1])
  #       datelines[line_date] = line_num
  #       # puts "#{line_num}: #{entry_date}"
  #     end
  #   end

  #   dates = datelines.keys
  #   dates << entry_date
  #   dates.sort!
  #   position = dates.index(entry_date)
  #   line = if position <= 0
  #            0
  #          elsif position == dates.size - 1
  #            -1
  #          else
  #            ### TODO: this is garbage
  #            datelines[datelines[position+1]]-1
  #          end

  #   puts "Dates: #{dates}, Entry position: #{line}"
  #   datelines[entry_date]
  # end

  # Get the file system path to the file
  def path
    @log_file.path
  end
end
