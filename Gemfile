source :gemcutter

gem "oauth", ">=0.4.5"
gem "rake"

if RUBY_VERSION < "1.9.0"
  gem "json", ">=1.1.1"
end

group :test do
  gem "rspec", "2.4.0"
  gem "ZenTest"
  gem "code_statistics"
  if RUBY_VERSION < "1.9.0"
    gem "rcov"
  else
    gem "simplecov"
  end
end
