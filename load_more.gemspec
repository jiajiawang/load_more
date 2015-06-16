$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "load_more/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "load_more"
  s.version     = LoadMore::VERSION
  s.authors     = ["Jiajia Wang"]
  s.email       = ["jjwang0506@gmail.com"]
  s.homepage    = "https://github.com/jiajiawang/load_more"
  s.summary     = "Load more plugin for active_record"
  s.description = "load_more provides a simple solution for performing load more queries with ActiveRecord."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "activerecord", "~> 4.0"

  s.add_development_dependency "sqlite3", "~> 1.3", ">= 1.3.0"
  s.add_development_dependency "rspec", "~> 3.2", ">= 3.2.0"
end
