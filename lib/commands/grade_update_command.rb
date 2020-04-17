# frozen_string_literal: true

require_relative '../diary'
require_relative 'mt_command'
require_relative '../team'
require_relative '../string_extensions'

# Implements grade level update functionality
# TODO: Tests!
class GradeUpdateCommand < MtCommand
  include Diary
  using StringExtensions

  # command(arguments, options)
  #   Create an entry in each team member's file
  def command(arguments, _options = nil)
    new_job_title, people = Array(arguments)
    Array(people).each do |person|
      employee = Employee.find person
      raise "no such team #{person}" unless employee

      text = File.read(employee.file.path)
      new_contents = text.gsub(/^Grade level:.*/, "Grade level: #{new_job_title}")
      employee.file.replace_with(new_contents)
    end
  end
end
