# frozen_string_literal: true

require 'attr_extras'
require_relative 'entity_file'
require_relative 'settings'

# Plumbing for log files
class LogFile
  include MtFile

  attr_reader :folder
  attr_value :log_file

  # Create a new log file
  # @param [EmployeeFolder] folder the containing folder
  def initialize(folder)
    @folder = folder.path
    @log_file = EntityFile.new folder, Settings.log_filename
  end

  # Get the file system path to the file
  def path
    @log_file.path
  end

  # Insert a DiaryEntry to the file in chronological order
  # @param [DiaryEntry] entry the entry to insert
  def insert(entry)
    make_backup
    before, after = entry.respond_to?(:date) ? divide_file(entry) : [IO.readlines(path), []]
    write_entry_to(before, entry, after)
    remove_backup
  end

  # replace the file with the given contents
  def replace_with(new_contents)
    make_backup
    File.write(path, new_contents)
    remove_backup
  end

  # Split the contents of the file into the part before the entry and the part after
  # @param [DiaryEntry] entry the entry to insert
  # @return [Array] an array with two entries: the chunk before where the entry belongs,
  #   and the chunk that belongs after
  # @example How to consume this method
  #   before, after = divide_file entry
  def divide_file(entry)
    entry_date = entry.date
    lines = IO.readlines path
    header_locations = get_header_locations lines
    dates = inject_new_entry_date(header_locations.keys, entry_date)

    insertion_position = dates.index entry_date
    case insertion_position
    when 0 then [[], lines]
    when dates.size - 1 then [lines, []]
    else
      demarcation = header_locations[dates[insertion_position + 1]] - 1
      [lines[0...demarcation], lines[demarcation..]]
    end
  end

  # Extract the lines in the file containing dates
  # @param [Array] lines the contents of the file
  # @return [Hash] a dictionary of date lines and their locations in the file
  def get_header_locations(lines = File.readlines(path))
    headers = {}
    lines.each_with_index do |line, line_num|
      dated_matches = /^===.*\((.*)\)/.match line
      unless dated_matches.to_a.empty?
        line_date = Time.parse dated_matches[1]
        headers[line_date] = line_num
        next
      end
      undated_header_matches = /^===(.*)/.match line
      headers[Time.at(0)] = line_num unless undated_header_matches.to_a.empty?
    end
    headers
  end

  # Rewrite the file, inserting the entry into the file at the correct point
  # @param [Array] before the contents of the file before the entry
  # @param [Array] entry the entry to insert
  # @param [Array] after the contents of the file after the entry
  # @example Writing an entry in the middle of a file
  #   write_entry_to(before, entry, after)
  def write_entry_to(before, entry, after)
    File.open(path, 'w') do |file|
      file.puts before
      file.puts "\n" unless entry.to_s.start_with? "\n" # ensure leading CR for Asciidoc
      file.puts entry
      file.puts after
    ensure
      file.close
    end
  end

  private

  # put the new entry date in the list of known dates for later sorting
  def inject_new_entry_date(timestamps, new_date)
    dates = timestamps << new_date
    dates.sort!
  end
end
