# frozen_string_literal: true

# rubocop:disable Lint/HandleExceptions
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:document) do |t|
    t.files = ['lib/**/*.rb']
    t.options = ['--exclude', 'spec/']
    t.stats_options = ['--list-undoc']
  end
rescue LoadError
end
# rubocop:enable Lint/HandleExceptions

desc 'Rebuild the overview and team directory documents'
task :rebuild do
  system *%w[rm -f */*/*/overview.adoc] || exit!(1)
  system *%w[./mt generate-overview-files] || exit!(1)
  task(:build).invoke
end

desc 'Run rubycritic against the solution to detect code quality issues'
task :rubycritic do
  system 'rubycritic' || exit!(1)
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

desc 'Run rubocop against the solution to find code quality issues'
task :rubocop do
  system 'rubocop', '.' || exit!(1)
end

desc 'Inspect the quality of the code'
task :quality do
  %I[rubycritic rubocop].each { |t| task(t).invoke }
end

desc 'Build the team directory document'
task :build do
  %I[test rebuild document].each { |t| task(t).invoke }
  # system 'asciidoctor', 'team-directory.adoc' || exit!(1)
  # puts 'Success, try `open team-directory.html` to view'
end

desc 'Mutation test example using DiaryEntry, to detect test suite gaps'
task :mutant do
  system *%w[bundle exec mutant --use rspec -I lib/ -r diary_entry DiaryEntry] || exit!(1)
end

desc 'Run guard, used during development'
task :guard do
  system *%w[bundle exec guard] || exit!(1)
end

task critic: :rubycritic
task docs: :document
task test: :spec
task default: :build
