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
    existing_lines = IO.readlines path
    write_entry_to(existing_lines, entry, [])
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
    before, after = divide_file entry
    write_entry_to(before, entry, after)
    remove_backup
  end

  # Split the contents of the file into the part before the entry and the part after
  # @param [DiaryEntry] entry the entry to insert
  # @return [Array] an array with two entries: the chunk before where the entry belongs, and the chunk that belongs after
  # @example How to consume this method
  #   before, after = divide_file entry
  def divide_file(entry)
    lines = IO.readlines path
    dateline_locations = get_dateline_locations lines
    
    entry_date = entry.date
    dates = dateline_locations.keys + [entry_date]
    dates.sort!

    insertion_position = dates.index entry_date
    if insertion_position.zero?
      [[], lines]
    elsif insertion_position == dates.size - 1
      [lines, []]
    else
      demarcation = dateline_locations[dates[insertion_position + 1]] - 1
      [lines[0...demarcation], lines[demarcation..-1]]
    end
  end

  # Extract the lines in the file containing dates
  # @param [Array] lines the contents of the file
  # @return [Hash] a dictionary of date lines and their locations in the file
  def get_dateline_locations(lines)
    datelines = {}
    lines.each_with_index do |line, line_num|
      matches = /^===.*\((.*)\)/.match line
      unless matches.to_a.empty?
        line_date = Time.parse matches[1]
        datelines[line_date] = line_num
      end
    end
    datelines
  end

  # Rewrite the file, inserting the entry into the file at the correct point
  # @param [Array] before the contents of the file before the entry
  # @param [Array] entry the entry to insert
  # @param [Array] after the contents of the file after the entry
  # @example Writing an entry in the middle of a file
  #   write_entry_to(before, entry, after)
  def write_entry_to(before, entry, after)
    open(path, 'w') do |file|
      file.puts before
      file.puts "\n" unless entry.to_s[0, 1] == "\n" # ensure leading CR for Asciidoc
      file.puts entry
      file.puts after
    end
  end
end
