require 'spec_helper'

describe "Amfetamine REST Helpers with conditions" do
  it "should work regular #all" do
    # TODO: Throw away and rewrite. Pfft.
    Dummy.cache.flush # Just to be uber sure

    query = {:title => 'Dummy'}
    dummy = build(:dummy)
    dummy.instance_variable_set('@notsaved',false)

    result = nil

    Dummy.prevent_external_connections! do |rc|
      rc.get { [dummy]}
      result = Dummy.all(:conditions => query)
    end

    result2 = Dummy.all(:conditions => query) # No errors raised means it got it from the cache
    result.should == result2
    result.should include(dummy)

    Dummy.prevent_external_connections! do |resource|
      resource.delete {}
      dummy.destroy
    end

    lambda {Dummy.all(:conditions => query) }.should raise_exception
  end

  it "should work with nested resource #all" do
    # TODO: Throw away and rewrite
    Dummy.cache.flush # Just to be uber sure
    Child.cache.flush

    query = {:title => 'Child'}
    dummy = build(:dummy)
    child = build(:child)
    dummy.children << child

    dummy.instance_variable_set('@notsaved',false)
    child.instance_variable_set('@notsaved',false)

    result = nil
    Child.prevent_external_connections! do |r|
      r.get(path: "/dummies/#{dummy.id}/children") {[child]}
      result = dummy.children.all(:conditions => query)
    end
    result2 = dummy.children.all(:conditions => query) # No errors raised means it got it from the cache
    result.should == result2
    result.should include(child)
    

    Child.prevent_external_connections! do |r|
      r.delete {}
      child.destroy
    end
    
    child.should_not be_cached

    lambda {dummy.children.all(:conditions => query, :force => true) }.should raise_exception
  end

  it "should work with normal resource #find" do
    dummy = build(:dummy)
    query = { :title => 'Dummy' }

    Dummy.stub_responses! do |r|
      r.get(:path => "/dummies/#{dummy.id}", :code => 200) { dummy }
      r.get(:path => "/dummies/#{dummy.id}", :code => 200, :query =>  query) { dummy }
      r.delete(:path => "/dummies/#{dummy.id}", :code => 200) {}
    end

    Dummy.cache.flush

    dummy.instance_variable_set('@notsaved',false)

    result = Dummy.find(dummy.id)
    result.should == dummy

    result2 = Dummy.find(dummy.id, :conditions => query)
    result2.should == result

    dummy.destroy

    dummy.should_not be_cached
  end


  it "should work with nested resource #find" do
    Dummy.cache.flush
    Child.cache.flush

    query = { :title => 'Dummy' }
    dummy = build(:dummy)
    child = build(:child)
    dummy.children << child

    dummy.instance_variable_set('@notsaved',false)
    child.instance_variable_set('@notsaved',false)

    result = nil
    Child.prevent_external_connections! do |r|
      r.get { child }
      result = dummy.children.find(dummy.id, :conditions =>  query)
    end

    result.should == child

    result2 = dummy.children.find(dummy.id, :conditions => query)
    result2.should == result

    Child.prevent_external_connections! do |r|
      r.delete {}
      child.destroy
    end

    child.should_not be_cached
  end
end
