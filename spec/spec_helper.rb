require 'simplecov'
require 'simplecov-rcov'
require 'pry'

if ENV['COVERAGE'] && (RUBY_ENGINE == "ruby")
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

require File.expand_path("../../lib/amfetamine.rb", __FILE__)
require 'helpers/active_model_lint'

require 'dummy/dummy_rest_client'
require 'dummy/configure'
require 'dummy/child'
require 'dummy/dummy'
require 'dummy/teacher'
require 'dummy/infant'

require 'fakeweb'
require 'json'

# Fakeweb to stub server responses, still want to do integration tests on the rest client
FakeWeb.allow_net_connect = false
def build(object)
  {
    :dummy => lambda { Dummy.new({:title => 'Dummy', :description => 'Crash me!', :id => Dummy.children.length + 1})},
    :child => lambda { Child.new({:title => 'Child', :description => 'Daddy!', :id => Child.children.length + 1}) },
    :dummy2 => lambda { Dummy2.new({:title => 'Dummy2', :description => 'Daddy!', :id => Dummy2.children.length + 1})},
    :teacher => lambda { Teacher.new({:name => 'Teacher', :id => Teacher.children.length + 1})},
    :infant => lambda { Infant.new({:name => 'Infant', :id => Infant.children.length + 1})}
  }[object].call
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.after(:each) { Amfetamine::Config.memcached_instance.flush }
  config.after(:each) { Dummy.restore_rest_client; Child.restore_rest_client }
  config.before(:each) { Dummy.save_rest_client; Child.save_rest_client }
  config.before(:each) { Dummy.resource_suffix = '' }
  config.order = "random"
end
