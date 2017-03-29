begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
end

desc 'Rebuild the overview and team directory documents'
task :rebuild do
  system('rm -f */*/*/overview.adoc') || exit!(1)
  system('./mt gen-overview-files') || exit!(1)
  task(:build).invoke
end

desc 'Build the YARD documentation'
task :document do
  system('yard doc') || exit!(1)
  puts 'Success, try `open doc/index.html` to view'
end

desc 'Run flog against the solution'
task :flog do
  system('flog . -spec') || exit!(1)
end

desc 'Inspect the quality of the code'
task :quality do
  task(:flog).invoke
end

desc 'Build the team directory document'
task :build do
  task(:test).invoke
  task(:rebuild).invoke
  task(:document).invoke
  system('asciidoctor team-directory.adoc') || exit!(1)
  puts 'Success, try `open team-directory.html` to view'
end

task test: :spec
task default: :build
