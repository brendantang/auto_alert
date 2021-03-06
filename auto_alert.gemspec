require_relative "lib/auto_alert/version"

Gem::Specification.new do |spec|
  spec.name = "auto_alert"
  spec.version = AutoAlert::VERSION
  spec.authors = ["Brendan Tang"]
  spec.email = ["b@brendantang.net"]
  spec.homepage = "https://github.com/brendantang/auto_alert"
  spec.summary = "Automatically raise and dismiss alerts on your ActiveRecord models."
  spec.description = "A plugin for Rails which makes it easy to specify conditions to raise or resolve alert records associated with your ActiveRecord models."
  spec.license = "MIT"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.1.3.2"
end
