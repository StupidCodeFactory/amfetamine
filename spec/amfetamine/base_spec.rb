require 'spec_helper'

# Integration tests :)
describe Amfetamine::Base do
  describe "Dummy, our ever faitful test subject" do
    # Some hight level tests, due to the complexity this makes it a lot easier to refactor
    let(:dummy) { build(:dummy) }
    subject { dummy }

    it { should be_valid }
    its(:title) { should ==('Dummy')}
    its(:description) { should ==('Crash me!')}
    its(:to_json) { should match(/dummy/) }

  end

  describe "Class dummy, setup with Amfetamine::Base" do
    let(:dummy) { build(:dummy) }
    let(:dummy2) { build(:dummy) }
    subject { Dummy}

    it { should be_cacheable }

    context "#attributes" do
      it "should update attribute correctly if I edit it" do
        dummy.title = "Oh a new title!"
        dummy.attributes['title'].should == "Oh a new title!"
      end

      it "should include attributes in json" do
        dummy.title = "Something new"
        dummy.to_json.should match(/Something new/)
      end
    end

    context "#find" do
      it "should find dummy" do
        dummy.instance_variable_set('@notsaved', false)
        Dummy.prevent_external_connections! do |r|
          r.get { dummy }
          response = Dummy.find(dummy.id)
          response.should == dummy
          response.should be_cached
        end
      end

      it "should return nil if object not found" do
        lambda {
        Dummy.prevent_external_connections! do |r|
          r.get(:code => 404) {}
          Dummy.find(dummy.id * 2).should be_nil
        end
        }.should raise_exception(Amfetamine::RecordNotFound)
      end
    end

    context "#all" do
      it "should find all if objects are present" do
        dummies = []
        dummy.instance_variable_set('@notsaved', false)
        dummy2.instance_variable_set('@notsaved', false)

        Dummy.prevent_external_connections! do |r|
          r.get {[dummy,dummy2]}
          dummies = Dummy.all
        end

        dummies.should include(dummy)
        dummies.should include(dummy2)
        dummies.length.should eq(2)
      end

      it "should return empty array if objects are not present" do
        Dummy.prevent_external_connections! do |r|
          r.get(:code => 200) {[]}

          Dummy.all.should be_empty
        end
      end
    end

    context "#create" do
      it "should create an object if data is correct" do
        Dummy.prevent_external_connections! do |r|
          r.post(:code => 201) {}
          new_dummy = Dummy.create({:title => 'test', :description => 'blabla'})
          new_dummy.should be_a(Dummy)
          new_dummy.should_not be_new
          new_dummy.should be_cached
        end
      end

      it "sets errors hash if local validations fail" do
        new_dummy = Dummy.create({ title: 'test' })
        new_dummy.should be_new
        new_dummy.errors.messages.should eql({ description: ["can't be blank"] })
        new_dummy.should_not be_cached
      end

      it "sets errors hash if remote validations fail" do
        error_message = "has already been taken"
        Dummy.prevent_external_connections! do |r|
          r.post(code: 422) { { title: [error_message] } }
          new_dummy = Dummy.create({ title: 'test', description: 'test' })
          new_dummy.should be_new
          new_dummy.errors.messages.should eql({ title: [error_message] })
          new_dummy.should_not be_cached
        end
      end
    end

    context "#update" do
      before do
        dummy.send(:notsaved=, false)
      end

      it "should update if response is succesful" do
        Dummy.prevent_external_connections! do |r|
          r.put {}
          dummy.update_attributes({:title => 'zomg'})
        end
        dummy.should_not be_new
        dummy.title.should eq('zomg')
        dummy.should be_cached
      end

      it "should return true for successful updates even with disabled caching" do
        Dummy.disable_caching = true
        Dummy.prevent_external_connections! do |r|
          r.put {}
          dummy.update_attributes({ :title => 'zomg' }).should be_true
        end
        Dummy.disable_caching = false
      end

      it "sets errors hash if local validations fail" do
        dummy.update_attributes({ title: "" })
        dummy.errors.messages.should eql({ title: ["can't be blank"] })
      end

      it "sets errors hash if remote validations fail" do
        error_message = "has already been taken"
        Dummy.prevent_external_connections! do |r|
          r.put(code: 422) { { title: [error_message] } }
          dummy.update_attributes({ title: "abc" })
          dummy.errors.messages.should eql({ title: [error_message] })
        end
      end

      it "should not do a request if the data doesn't change" do
        # Assumes that dummy.update would raise if not within stubbed request.
        dummy.update_attributes({:title => dummy.title})
        dummy.errors.should be_empty
      end
    end

    context "#save" do
      let(:dummy2) { dummy.dup}
      before(:each) do
        dummy.send(:notsaved=, true)
        dummy2 = dummy.dup
        dummy.send(:id=, nil)
      end

      it "should update the id if data is received from post" do
        old_id = dummy.id
        Dummy.prevent_external_connections! do |r|
          r.post(code:201) { dummy2 }

          dummy.save
        end
        dummy.id.should == old_id
        dummy.attributes[:id].should == old_id
      end

      it "should update attributes if data is received from update" do
        dummy.send(:notsaved=, false)
        old_id = dummy.id
        dummy.title = "BLABLABLA"
        Dummy.prevent_external_connections! do |r|
          r.put {dummy}
          dummy.title = "BLABLABLA"
          dummy.save
        end
        dummy.id.should == old_id
        dummy.title.should == "BLABLABLA"
        dummy.attributes[:title] = "BLABLABLA"
      end
    end

    context "#delete" do
      before(:each) do
        dummy.send(:notsaved=, false)
      end

      it "should delete the object if response is succesful" do
        Dummy.prevent_external_connections! do |r|
          r.delete {}
          dummy.destroy
        end

        dummy.should be_new
        dummy.id.should be_nil
        dummy.should_not be_cached
      end

      it "should return false if delete failed" do
        Dummy.prevent_external_connections! do |r|
          r.delete(code: 422) {}
          dummy.destroy
        end
        dummy.should_not be_new
        dummy.should_not be_cached
      end
    end
  end

  describe "Features and bugs" do
    it "should raise an exception if cached args are nil" do
      lambda { Dummy.build_object(nil) }.should raise_exception(Amfetamine::InvalidCacheData)
    end

    it "should raise an exception if cached args do not contain an ID" do
      lambda { Dummy.build_object(:no_id => 'present') }.should raise_exception(Amfetamine::InvalidCacheData)
    end

    it "should raise correct exception is data is not expected format" do
      lambda { Dummy.build_object([]) }.should raise_exception(Amfetamine::InvalidCacheData)
    end

    it "should receive data when doing a post" do
      Dummy.prevent_external_connections! do
        dummy = build(:dummy)
        Dummy.rest_client.should_receive(:post).with("/dummies", :body => dummy.to_hash_with_head).
          and_return(Amfetamine::FakeResponse.new('post', 201, lambda { dummy }))
        dummy.save
      end
    end

  end

end
