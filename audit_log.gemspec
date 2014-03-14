$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "audit_log/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "audit_log"
  s.version     = AuditLog::VERSION
  s.authors     = ["Connectere"]
  s.email       = ["ti@connectere.agr.br"]
  s.homepage    = "http://www.connectere.agr.br/"
  s.summary     = "Logs of model changes, including nested attributes."
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 4"
  s.add_dependency "rails-observers"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
