source 'https://rubygems.org'

# Install omnibus
# gem 'omnibus', '~> 7.0', git: 'https://github.com/chef/omnibus', ref: "f8f202cdffe5a77aed4c4884f302a38be3eabc64"
gem 'omnibus', '~> 8.0'

# Use Chef's software definitions. It is recommended that you write your own
# software definitions, but you can clone/fork Chef's to get you started.
gem 'omnibus-software', github: 'opscode/omnibus-software', ref: "8d91dc6a566aba77c864678680d4142561b2f655"
gem 'active_interaction'
gem 'activesupport', '~> 5.2', require: false
gem 'attr_lazy'
gem 'cleanroom'
gem 'commander'
gem 'dotenv'
gem 'dux'
gem 'git'
gem 'rake'
gem 'rb-readline'
gem 'pry'
gem 'ptools'
gem 'rack', '>= 2.0.6'
gem 'rubyzip', '>= 1.2.2', '< 3.0'
gem 'semantic'

# This development group is installed by default when you run `bundle install`,
# but if you are using Omnibus in a CI-based infrastructure, you do not need
# the Test Kitchen-based build lab. You can skip these unnecessary dependencies
# by running `bundle install --without development` to speed up build times.
group :development do
  # Use Berkshelf for resolving cookbook dependencies
  gem 'berkshelf', '~> 7.0'
  # Use Test Kitchen with Vagrant for converging the build environment
  gem 'test-kitchen',    '~> 1.4'
  gem 'kitchen-vagrant', '~> 0.18'
end
