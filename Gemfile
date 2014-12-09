source "https://rubygems.org"

gemspec

ruby '2.0.0', engine: 'jruby', engine_version: '1.7.15'

gem 'yaml-write-stream', path: '~/workspace/yaml-write-stream' # github: 'camertron/yaml-write-stream'
gem 'rosette-core', '~> 1.0.0', path: '~/workspace/rosette-core'

gem 'jbundler'

group :development, :test do
  gem 'pry', '~> 0.9.0'
  gem 'pry-nav'
  gem 'rake'
end

group :test do
  gem 'rspec'
end
