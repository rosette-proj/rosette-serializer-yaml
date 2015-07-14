source "https://rubygems.org"

gemspec

ruby '2.0.0', engine: 'jruby', engine_version: '1.7.15'

gem 'rosette-core', '~> 1.0.0', github: 'rosette-proj/rosette-core'

group :development, :test do
  gem 'expert', '~> 1.0.0'
  gem 'pry', '~> 0.9.0'
  gem 'pry-nav'
  gem 'rake'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'rspec'
end
