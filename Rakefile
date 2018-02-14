# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
end

desc 'Rebuild the overview and team directory documents'
task :rebuild do
<<<<<<< HEAD
  system *%w[rm -f */*/*/overview.adoc] || exit!(1)
  system *%w[./mt generate-overview-files] || exit!(1)
=======
  system(*%w[rm -f */*/*/overview.adoc]) || exit!(1)
  system(*%w[./mt generate-overview-files]) || exit!(1)
>>>>>>> 8ddb1b875ee9bdf1278c3c2d0352863f220df9d4
  task(:build).invoke
end

desc 'Build the YARD documentation'
task :document do
  system 'yard', 'doc' || exit!(1)
  puts 'Success, try `open doc/index.html` to view'
end

desc 'Run flay against the solution to detect code duplication'
task :flay do
  system 'flay', '.' || exit!(1)
end

desc 'Run flog against the solution to detect code complexity'
task :flog do
  system *%w[flog . -spec] || exit!(1)
end

desc 'Run reek against the solution to detect code smells'
task :reek do
  system 'reek', '.' || exit!(1)
end

desc 'Inspect the quality of the code'
task :quality do
  %I[flay flog reek].each { |t| task(t).invoke }
end

desc 'Build the team directory document'
task :build do
  %I[test rebuild document].each { |t| task(t).invoke }
  system 'asciidoctor', 'team-directory.adoc' || exit!(1)
  puts 'Success, try `open team-directory.html` to view'
end

desc 'Mutation test example using DiaryEntry, to detect test suite gaps'
task :mutant do
  system *%w[bundle exec mutant --use rspec -I lib/ -r diary_entry DiaryEntry] || exit!(1)
end

task test: :spec
task default: :build
