require 'rake/rdoctask'

desc 'Generate RDoc'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title = "Twitter4R v#{Twitter::Version.to_version}: Idiomatic Ruby Open Source Library for the Twitter REST and Search APIs"
#  rdoc.template = File.join(File.dirname(__FILE__), '..', 'config', 'rdoc_template.rb')
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README.md' << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('CHANGES')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('examples/**/*.rb')
end
