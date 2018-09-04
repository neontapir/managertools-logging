# frozen_string_literal: true

require_relative 'diary'
require_relative 'team'

# A team meeting
class MultipleMemberCommand
  include Diary

  # @!method command(arguments)
  #   Create an entry in each team member's file
  def command(arguments)
    raise 'missing person name argument' unless arguments.first

    members = arguments.map do |person|
      employee = Employee.find(person)
      raise "unable to find employee '#{person}'" unless employee
      employee
    end

    entry = nil
    members.each do |employee|
      entry ||= get_entry :multiple_member, employee
      employee.file.insert entry
    end
  end
end
