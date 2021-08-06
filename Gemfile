# frozen_string_literal: true

source 'https://rubygems.org'

gem 'asciidoctor'
gem 'attr_extras'
gem 'chronic'
gem 'chronic_duration'
gem 'facets'
gem 'highline'
gem 'namecase'
gem 'os'
gem 'psych', '~> 3.3'
gem 'rake'
gem 'sentimental'
gem 'settingslogic'
gem 'thor'
gem 'titleize'
gem 'unicode'

group :dev, optional: true do
  gem 'fasterer'
  gem 'overcommit'
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-nav' # rubocop: disable Bundler/OrderedGems
  gem 'ruby-lint'
end

group :docs, optional: true do
  gem 'yard'
end

group :ide, optional: true do
  # gem 'bundler-stats'
  gem 'debase', '>= 0.2.5.beta'
  gem 'fastri'
  gem 'rcodetools'
  gem 'ruby-debug-ide'
  gem 'semgrep'
  gem 'solargraph' unless Gem.win_platform? # until nokogiri supported for Ruby 2.7 on Windows
  # ...\managertools-logging> gem install nokogiri --platform=ruby -- --use-system-libraries
  # Temporarily enhancing PATH for MSYS/MINGW...
  # Building native extensions with: '--use-system-libraries'
  # This could take a while...
  # Successfully installed nokogiri-1.10.7
  # 1 gem installed
end

group :quality, optional: true do
  gem 'flay'
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubycritic'
  gem 'sandi_meter' #, '~> 1.2'
  gem 'tailor'
end

group :test do
  gem 'aruba' #, '> 0.14.10'
  gem 'fuubar'
  gem 'guard-rspec'
  gem 'mutant-rspec'
  gem 'rspec'
  gem 'rspec-pride'
  gem 'simplecov'
  gem 'timecop'
  gem 'wdm' #, '>= 0.1.0' if Gem.win_platform?
end
