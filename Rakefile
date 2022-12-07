# frozen_string_literal: true

require 'English'

# rubocop:disable Lint/SuppressedException
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
# rubocop:enable Lint/SuppressedException

def check_installed(program)
  _ = system("hash #{program} &> /dev/null")
  result = $CHILD_STATUS
  result.exitstatus.eql?(0)
end

def call_with_check(command_string)
  call = command_string.split
  program = call.first
  if check_installed(program)
    system(command_string) || exit!(1)
  else
    warn "#{program} not installed, skipping"
  end
end

desc 'Rebuild the overview and team directory documents'
task :rebuild do
  system(*%w[rm -f */*/*/overview.adoc]) || exit!(1)
  system(*%w[bundle exec ./mt generate-overview-files]) || exit!(1)
  task(:build).invoke
end

desc 'Run rubycritic against the solution to detect code quality issues'
task :rubycritic do
  system(*%w[bundle exec rubycritic]) || exit!(1)
end

desc 'Open coverage report'
task :coverage do
  system(*%w[open coverage/index.html]) || exit!(1)
end

desc 'Run flay against the solution to detect code duplication'
task :flay do
  system(*%w[bundle exec flay .]) || exit!(1)
end

desc 'Run flog against the solution to detect code complexity'
task :flog do
  system(*%w[bundle exec flog . -spec]) || exit!(1)
end

desc 'Run reek against the solution to detect code smells'
task :reek do
  system(*%w[bundle exec reek .]) || exit!(1)
end

desc 'Run rubocop against the solution to find code quality issues'
task :rubocop do
  system(*%w[bundle exec rubocop .]) || exit!(1)
end

desc 'Run sandi_meter against the solution to find code quality issues'
task :sandi_meter do
  call_with_check 'sandi_meter -d'
end

desc 'Run tailor against the lib folder to find code quality issues'
task :tailor do
  require 'tailor/rake_task'
  Tailor::RakeTask.new
end

desc 'Inspect the quality of the code'
task :quality do
  %I[rubycritic rubocop sandi_meter tailor].each { |t| task(t).invoke }
end

desc 'Build the team directory document'
task :build do
  %I[test scan rebuild document].each { |t| task(t).invoke }
  # system 'asciidoctor', 'team-directory.adoc' || exit!(1)
  # puts 'Success, try `open team-directory.html` to view'
end

desc 'Scan code for vulnerabilities'
task :scan do
  call_with_check 'semgrep --config=p/r2c-ci .'
end

desc 'Mutation test example using DiaryEntry, to detect test suite gaps'
task :mutant do
  system({ 'NO_SIMPLECOV' => 'true' }, *%w[bundle exec mutant run --use rspec --include lib --require entries/diary_entry DiaryEntry]) || exit!(1)
end

desc 'Run guard, used during development'
task :guard do
  system(*%w[bundle exec guard]) || exit!(1)
end

desc 'Run RubyCritic, alias for rubycritic'
task critic: :rubycritic

desc 'Generate documentation, alias for document'
task docs: :document

desc 'Run unit tests'
task :rspec do
  system(*%w[bundle exec rspec]) || exit!(1)
end

desc 'Run unit tests, alias for rspec'
task test: :rspec

task default: :build
