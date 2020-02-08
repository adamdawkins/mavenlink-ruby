# frozen_string_literal: true

require "rake/testtask"
require "rubocop/rake_task"

task default: %i[test]

Rake::TestTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb"
end

RuboCop::RakeTask.new
