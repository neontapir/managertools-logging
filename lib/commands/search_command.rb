# frozen_string_literal: true

require_relative '../employee_finder'
require_relative 'mt_command'

# Search the data folder for matching people
class SearchCommand < MtCommand
  include EmployeeFinder

  # command(arguments, options)
  #   Search the data root for matching folders and display
  def command(arguments, _ = nil)
    search_string = Array(arguments).first
    raise 'missing specification argument' unless search_string

    search(search_string)
      .map { |e| e.file.folder }
      .each { |folder| Settings.console.say folder }
  end
end
