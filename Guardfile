# frozen_string_literal: true

directories(%w[lib lib/commands lib/entries spec]).select do |d|
  Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")
end

# To debug, courtesy of https://github.com/guard/guard/wiki/Understanding-Guard
# watch(%r{^lib/(.+)\.rb$}) do |m|
#   "spec/#{m[1]}_spec.rb" # .tap do |result| 
#      Guard::UI.info "Sending changes to RSpec: #{result.inspect}"
#      Guard::UI.info "The original match is: #{m.inspect}"
#   end
# end

guard :rspec, cmd: 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(commands|entries)/(.+)\.rb$}) { |m| "spec/#{m[2]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }

  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)
end
