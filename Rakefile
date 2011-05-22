require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "redis-classy"
  gem.homepage = "http://github.com/kenn/redis-classy"
  gem.license = "MIT"
  gem.summary = "Class-style namespace prefixing for Redis"
  gem.description = "Class-style namespace prefixing for Redis"
  gem.email = "kenn.ejima@gmail.com"
  gem.authors = ["Kenn Ejima"]
end
Jeweler::RubygemsDotOrgTasks.new

task :default => :spec
task :spec do
  exec "rspec spec/redis-classy_spec.rb"
end
