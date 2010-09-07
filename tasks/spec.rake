gem 'rspec'
require('rspec')
require('rspec/core/rake_task')
#require('rcov_report')

gem 'ZenTest'
require('autotest')
require('autotest/rspec2')

namespace :spec do
  desc "Run specs"
  RSpec::Core::RakeTask.new(:html) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.spec_opts = ['--format', 'html:doc/spec/index.html']
    t.rcov = true
    t.rcov_opts = ['--options', "spec/spec.opts"]
    t.fail_on_error = true
  end

  desc "Run specs and output to console"
  RSpec::Core::RakeTask.new(:console) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.rcov = true
    t.rcov_opts = IO.readlines("#{ENV['PWD']}/spec/rcov.opts").map { |line| line.chomp.split(' ') }.flatten
    t.fail_on_error = true
  end
end
