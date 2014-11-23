# -*- encoding: utf-8 -*-
require File.expand_path('../lib/redis_classy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kenn Ejima"]
  gem.email         = ["kenn.ejima@gmail.com"]
  gem.description   = %q{Class-style namespace prefixing for Redis}
  gem.summary       = %q{Class-style namespace prefixing for Redis}
  gem.homepage      = "http://github.com/kenn/redis-classy"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "redis-classy"
  gem.require_paths = ["lib"]
  gem.version       = RedisClassy::VERSION

  gem.add_runtime_dependency "redis-namespace", "~> 1.0"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "bundler"

  # For Travis
  gem.add_development_dependency "rake"
end
