require 'simplecov'
require 'simplecov-rcov'
require 'pry'

if ENV['COVERAGE'] && (RUBY_ENGINE == "ruby")
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

require File.expand_path("../../lib/amfetamine.rb", __FILE__)

# spec helpers
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each { |file| require file }

# Dummies (factories)
Dir[File.dirname(__FILE__) + '/dummy/*.rb'].each { |file| require file }

Amfetamine::Config.configure do |config|
  config.memcached_instance = 'localhost:11211'
  config.rest_client = DummyRestClient
end

require 'fakeweb'
require 'json'

# Fakeweb to stub server responses, still want to do integration tests on the rest client
FakeWeb.allow_net_connect = false
def build(object)
  {
    :dummy   => lambda { Dummy.new({   :title => 'Dummy',  :description => 'Crash me!', :id => IdPool.next })},
    :child   => lambda { Child.new({   :title => 'Child',  :description => 'Daddy!',    :id => IdPool.next }) },
    :dummy2  => lambda { Dummy2.new({  :title => 'Dummy2', :description => 'Daddy!',    :id => IdPool.next })},
    :teacher => lambda { Teacher.new({ :name => 'Teacher', :id => IdPool.next })},
    :infant  => lambda { Infant.new({  :name => 'Infant',  :id => IdPool.next })}
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
