# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  voxpupuli_test_version = ENV['OPENVOX_GEM_VERSION'].to_s.empty? ? '~> 7.0' : '~> 14.0'
  gem 'voxpupuli-test', voxpupuli_test_version, :require => false
  gem 'coveralls',                  :require => false
  gem 'simplecov-console',          :require => false
  gem 'puppet_metadata', '~> 3.5',  :require => false
end

group :development do
  gem 'guard-rake',               :require => false
  gem 'overcommit', '>= 0.39.1',  :require => false
end

group :system_tests do
  gem 'voxpupuli-acceptance', '~> 3.0',  :require => false
end

group :release do
  gem 'voxpupuli-release', '~> 3.0',  :require => false
end

gem 'rake', :require => false
gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false, :groups => [:test]

if ENV['OPENVOX_GEM_VERSION'].to_s.empty?
  puppetversion = ENV['PUPPET_GEM_VERSION'] || '~> 7.24'
  gem 'puppet', puppetversion, :require => false, :groups => [:test]
  # Puppet 8.10 mutates OpenSSL::SSL::SSLContext::DEFAULT_PARAMS, which is
  # frozen by openssl 4.x. Keep the Puppet test runtime on openssl 3.x.
  gem 'openssl', '< 4', :require => false, :groups => [:test]
else
  gem 'openvox', ENV['OPENVOX_GEM_VERSION'], :require => false, :groups => [:test]
end

# vim: syntax=ruby
