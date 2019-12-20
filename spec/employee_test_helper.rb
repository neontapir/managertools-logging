# frozen_string_literal: true

require './lib/employee'

# Set expectations for an employee or employee specification
module EmployeeTestHelper
  def proper?(employee, team, first, last)
    expect(employee).not_to be_nil

    [:team, :first, :last].each do |item|
      expect(get_value(employee, item)).to eq binding.local_variable_get(item)
    end
  end

  private

  def get_value(employee, key)
    employee.respond_to?(:fetch) ? employee.fetch(key) : employee.send(key)
  end
end
