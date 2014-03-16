source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.

#### SPECIAL GEMFILE BLOCK START
def private_gem(name)
  gem name, git: "https://#{ENV['GITHUB_TOKEN']}:x-oauth-basic@github.com/mharris717/#{name}.git", branch: :master
end
#### SPECIAL GEMFILE BLOCK END

group :development do
  gem "rspec", "~> 2.8.0"
  gem "rdoc", "~> 3.12"
  gem "bundler", ">= 1.0"
  gem "jeweler", "~> 1.8.7"
 # gem "rcov", ">= 0"

 gem 'guard'
 gem 'guard-rspec'
 gem 'guard-spork'

 gem 'rb-fsevent', '~> 0.9'

 gem 'lre'

 gem 'rr'
end

gem 'mharris_ext'
gem 'andand'
gem 'grit'
private_gem 'mongoid_gem_config'
private_gem 'remote_cache'