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
    make_backup
    lines = IO.readlines(path)
    write_entry_to(lines, entry, [])
    remove_backup
  end

  # Get the file system path to the file
  def path
    @log_file.path
  end

  # Insert a DiaryEntry to the file in chronological order
  # @param [DiaryEntry] entry the entry to insert
  def insert(entry)
    make_backup
    before, after = divide_file(entry)
    write_entry_to(before, entry, after)
    remove_backup
  end

  # Split the contents of the file into the part before the entry and the part after
  # @param [DiaryEntry] entry the entry to insert
  def divide_file(entry)
    lines = IO.readlines(path)
    datelines = get_datelines(lines)
    dates = datelines.keys
    dates << entry.date
    dates.sort!
    
    position = dates.index(entry.date)
    result = if position == 0
      [[], lines]
    elsif position == dates.size - 1
      [lines, []]
    else
      line_no = datelines[dates[position+1]]-1
      [lines[0...line_no], lines[line_no..-1]]
    end
    result
  end

  # Extract the lines in the file containing dates
  # @param [Array] lines the contents of the file
  def get_datelines(lines)
    datelines = {}
    lines.each_with_index do |line, line_num|
      matches = /^===.*\((.*)\)/.match line
      unless matches.to_a.empty?
        line_date = Time.parse(matches[1])
        datelines[line_date] = line_num
      end
    end
    datelines
  end

  # Write the entry into the file at the correct point
  # @param [Array] before the contents of the file before the entry
  # @param [Array] entry the entry to insert
  # @param [Array] after the contents of the file after the entry
  def write_entry_to(before, entry, after)
    open(path, 'w') do |file|
      file.puts before
      file.puts "\n" unless entry.to_s[0, 1] == "\n" # ensure leading CR for Asciidoc
      file.puts entry
      file.puts after
    end
  end
end
