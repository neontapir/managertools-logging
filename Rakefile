begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

desc "Rebuild the overview and team directory documents"
task :rebuild do
  system( "rm -f */*/*/overview.adoc") or exit!(1)
  system( "./gen-overview-files") or exit!(1)
  task(:build).invoke
end

desc "Build the team directory document"
task :build do
  task(:test).invoke
  task(:rebuild).invoke
  system( "asciidoctor team-directory.adoc" ) or exit!(1)
  puts "Success, try `open team-directory.html` to view"
end

task :test => :spec
task :default => :build
