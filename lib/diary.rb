require 'highline/import'
require 'require_all'
require_rel '.'

# Base functionality for all entry types
module Diary
  def record_to_file(type, person)
    employee = Employee.get(person, type)
    entry = get_entry(type, employee)
    log_file = employee.file
    log_file.ensure_exists
    log_file.append entry
  end

  def get_entry(type, employee)
    data = if (@global_opts && @global_opts.template) || (@cmd_opts && @cmd_opts.template)
             create_blank_hash
           else
             create_entry type, employee.to_s
           end
    entry_type = get_entry_type(type)
    entry_type.new data
  end

  def create_entry(type, name)
    result = create_blank_hash

    entry_type = get_entry_type type
    puts entry_type.send(:prompt, name)

    elements = get_entry_elements(type)
    add_elements(result, elements)

    result
  end

  def get_entry_type(name)
    entry_type_name = name.to_s.tr('_', ' ').split(' ').map(&:capitalize).join
    Kernel.const_get("#{entry_type_name}Entry")
  end

  def add_elements(result, elements)
    elements.each do |item|
      if item.kind_of? DiaryElement
        add_element result, item.key, item.prompt, item.default
      elsif item.kind_of? Array
        add_element result, item[0], item[1]
      else
        add_element result, item
      end
    end
  end

  def add_element(result, key, prompt = key.to_s.capitalize, default = DiaryElement::NONE)
    result[key] = ask "#{prompt}: " do |q|
      q.default = default
    end
  end

  def create_blank_hash
    hash = Hash.new('')
    hash[:datetime] = Time.now
    hash
  end

  def get_entry_elements(type)
    entry_type = get_entry_type type
    entry_type.send(:elements_array)
  end
end
