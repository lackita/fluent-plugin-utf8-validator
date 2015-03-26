# encoding: utf-8
Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-utf8-validator"
  gem.version     = "0.1.0"
  gem.has_rdoc    = false
  gem.email       = "cessien@athenahealth.com"
  gem.homepage    = "https://github.com/cessien/fluent-plugin-utf8-validator"
  gem.description = "A Fluentd output plugin that validates utf8 byte sequences and escape non-valid utf8 characters."
  gem.summary     = "[A Fluentd output plugin that validates utf8 byte sequences and escape non-valid utf8 characters."
  gem.files       = ['lib/fluent/plugin/out_utf8_validator.rb']
  gem.authors     = ["athenahealth"]
  gem.require_paths = ['lib']
  gem.license     = "Apache 2.0"
end
