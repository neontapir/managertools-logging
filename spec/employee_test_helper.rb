# frozen_string_literal: true

require './lib/employee'

# Set expectations for an employee or employee specification
module EmployeeTestHelper
  def proper?(employee, team, first, last)
    is_employee = employee.instance_of?(Employee)
    expect(employee).not_to be_nil
    employee_team = is_employee ? employee.team : employee.fetch(:team)
    expect(employee_team).to eq team
    employee_first = is_employee ? employee.first : employee.fetch(:first)
    expect(employee_first).to eq first
    employee_last = is_employee ? employee.last : employee.fetch(:last)
    expect(employee_last).to eq last
  end
end