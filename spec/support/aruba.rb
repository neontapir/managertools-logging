require 'aruba/rspec'

unless defined? MT
  MT = File.expand_path('../../../mt', __FILE__)
  load MT
end

Aruba.config.command_launcher = :in_process
Aruba.config.main_class = ManagerTools::Runner