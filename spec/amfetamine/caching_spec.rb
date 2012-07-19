require 'spec_helper'

describe Amfetamine::Cache do
  it "should return same data after all request has been made" do
    dummy = build(:dummy)
    dummy2 = build(:dummy)
    dummies = nil
    Dummy.prevent_external_connections! do |r|
      r.get { [dummy, dummy2]}
      dummies = Dummy.all
    end
    dummies_no_request = Dummy.all
    dummies.should == dummies
  end

  it "should return same data after find request has been made" do
    dummy = build(:dummy)
    return_dummy = nil
    Dummy.prevent_external_connections! do |r|
      r.get { dummy }
      return_dummy = Dummy.find(dummy.id) 
    end
    dummy_no_request = Dummy.find(dummy.id)
    dummy_no_request.should == return_dummy
  end

  it "should update the cache after a save has been made" do
    dummy = build(:dummy)
    dummy.instance_variable_set('@notsaved', false)
    dummy.title = 'blabla'
    Dummy.prevent_external_connections! do |r|
      r.put {}
      dummy.save
    end
    dummy2 = Dummy.find(dummy.id)
    dummy2.should == dummy
  end

end

