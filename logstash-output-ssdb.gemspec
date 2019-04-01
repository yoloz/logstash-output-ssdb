Gem::Specification.new do |s|
  s.name          = 'logstash-output-ssdb'
  s.version       = '0.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = '写入ssdb'
  s.description   = 'ssdb写入'
  s.homepage      = 'http://www.elastic.co/guide/en/logstash/current/index.html'
  s.authors       = ['yoloz']
  s.email         = 'z88897050@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency "logstash-codec-plain", '~> 3.0'
  s.add_development_dependency "logstash-devutils", '~> 0'
end
