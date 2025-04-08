# frozen_string_literal: true

source 'https://rubygems.org'

gem "abbrev", "~> 0.1.2"
gem 'asciidoctor', '~> 2.0'
gem 'attr_extras', '~> 7.1'
gem 'bundler-audit', '~> 0.9'
gem 'chronic', '~> 0.10'
gem 'chronic_duration', '~> 0.10'
gem 'facets', '~> 3.1'
gem 'highline', '~> 2.1'
gem "monitor", "~> 0.2.0"
gem 'namecase', '~> 2.0'
gem 'os', '~> 1.1'
gem 'psych', '~> 5.1'
gem 'rake', '~> 13'
gem 'sentimental', '~> 1.5'
gem 'settingslogic', '>= 2.0.9', git: 'https://github.com/pavelgyravel/settingslogic.git'
gem 'thor', '~> 1.2'
gem 'titleize', '~> 1.4'
gem 'unicode', '~> 0.4'

group :dev, optional: true do
  gem 'fasterer'
  gem 'overcommit'
#  gem 'parser', '>3'
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-nav' # rubocop: disable Bundler/OrderedGems
#  gem 'ruby-lint', '>=2.3'
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
  gem 'solargraph' # unless Gem.win_platform? # until nokogiri supported for Ruby 2.7 on Windows
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
  gem 'reek', '>6.1'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'rubycritic'
  gem 'sandi_meter' #, '~> 1.2'
  gem 'tailor'
end

group :test do
  gem 'aruba' #, '> 0.14.10'
  gem 'fuubar'
  gem 'guard-rspec'
  source 'https://gem.mutant.dev' do # license set with bundle config
    gem 'mutant-license'
  end
  gem 'mutant-rspec'
  gem 'rspec'
  gem 'rspec-pride'
  gem 'simplecov'
  gem 'timecop'
  gem 'wdm' #, '>= 0.1.0' if Gem.win_platform?
end
