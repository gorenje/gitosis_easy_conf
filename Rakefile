# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "gitosis_easy_conf"
  gem.homepage = "http://github.com/gorenje/gitosis_easy_conf"
  gem.license = "MIT"
  gem.summary = %Q{Make writing a gitosis configuration easier}
  gem.description = %Q{Easy gitosis configuration}
  gem.email = "gerrit.riessen@gmail.com"
  gem.authors = ["Gerrit Riessen"]

  gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
  gem.add_development_dependency "rake", ">= 0"
  gem.add_development_dependency "jeweler", ">= 0"
  gem.add_development_dependency "inifile", ">= 0"

  gem.add_runtime_dependency "inifile", ">= 0"
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gitosis_easy_conf #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
