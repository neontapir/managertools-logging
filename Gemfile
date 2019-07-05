# frozen_string_literal: true

source 'https://rubygems.org'

gem 'asciidoctor'
gem 'chronic'
gem 'commander'
gem 'facets'
gem 'highline'
gem 'namecase'
gem 'os'
gem 'settingslogic'
gem 'titleize'
gem 'unicode'

group :docs, optional: true do
  gem 'yard'
end

group :ide, optional: true do
  # gem 'bundler-stats'
  gem 'rake'
  gem 'rcodetools'
  gem 'solargraph'
end

group :quality, optional: true do
  gem 'flay'
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

group :test do
  gem 'guard-rspec'
  gem 'mutant-rspec'
  gem 'rspec'
  gem 'rspec-pride'
  gem 'simplecov'
  gem 'timecop'
  gem 'wdm', '>= 0.1.0' if Gem.win_platform?
end
