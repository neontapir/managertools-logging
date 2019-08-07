# frozen_string_literal: true

require_relative '../diary'
require_relative '../mt_data_formatter'
require_relative '../team'

# Implements personal goal functionality
class GoalCommand
  include Diary
  include MtDataFormatter

  # @!method command(arguments, options)
  #   Create a goal in each team member's file
  def command(arguments, _ = nil)
    args = Array(arguments)
    raise 'missing person name argument' unless args.first

    members = args.map do |person|
      employee = Employee.find(person)
      raise "unable to find employee '#{person}'" unless employee

      employee
    end

    entry = nil
    members.each do |employee|
      entry ||= get_entry(:goal, employee.to_s, applies_to: members.map(&:to_s).join(', '))
      employee.file.insert entry
    end
  end
end
