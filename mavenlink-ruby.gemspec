# frozen_string_literal: true

$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), "lib"))

Gem::Specification.new do |s|
  s.name = "mavenlink-ruby"
  s.version = "0.12.0"
  s.summary = "Ruby Mavenlink API Wrapper"
  s.description = "Inspired by Stripe's stripe-ruby"
  s.authors = ["Adam Dawkins"]
  s.email = "adam@dragondrop.uk"
  s.homepage = "https://rubygems.org/gems/mavenlink-ruby"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")

  s.require_paths = ["lib"]
  s.add_dependency "activesupport", ">= 6.0.0"
end
