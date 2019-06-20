# frozen_string_literal: true

source 'https://rubygems.org'

gem 'asciidoctor'
gem 'chronic'
gem 'command'
gem 'facets'
gem 'highline'
gem 'namecase'
gem 'optimist'
gem 'os'
gem 'settingslogic'
gem 'titleize'
gem 'unicode'

gem 'yard', require: false, group: :docs

group :quality, optional: true do
  gem 'flay'
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

group :ide, optional: true do
  # gem 'bundler-stats'
  gem 'rake'
  gem 'rcodetools'
  gem 'solargraph'
end

group :test do
  gem 'guard-rspec'
  gem 'mutant-rspec'
  gem 'rspec'
  gem 'should_not'
  gem 'simplecov'
  gem 'timecop'
  gem 'wdm', '>= 0.1.0' if Gem.win_platform?
end
