$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rosette/serializers/yaml/version'

Gem::Specification.new do |s|
  s.name     = "rosette-serializer-yaml"
  s.version  = ::Rosette::YamlSerializerVersion::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://github.com/camertron"

  s.description = s.summary = "A kinda streaming YAML serializer for the Rosette internationalization platform."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/*", "Gemfile", "History.txt", "README.md", "Rakefile", "rosette-serializer-yaml.gemspec"]
end
