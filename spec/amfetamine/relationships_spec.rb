require 'spec_helper'

describe Amfetamine::Relationships do
  let(:dummy) {build :dummy}
  let(:child) {build :child}

  context "Routing" do
    it "should generate correct paths" do
      dummy.children << child

      Child.rest_path.should == "/children"
      child.rest_path.should == "/children"
      child.singular_path.should == "/children/#{child.id}"
      dummy.children.rest_path.should == "/dummies/#{dummy.id}/children"

      Child.resource_suffix = '.json'
      child.rest_path.should == "/children.json"
      dummy.children.rest_path.should == "/dummies/#{dummy.id}/children.json"
      child.singular_path.should == "/children/#{child.id}.json"

      Child.resource_suffix = ''
      child.dummy.singular_path.should == "/dummies/#{dummy.id}/children/#{child.id}"
      dummy.children.find_path(child.id).should == "/dummies/#{dummy.id}/children/#{child.id}"
    end

    it "should raise error if nested path lacks parent id" do
      child = Child.new({:title => 'test', :dummy_id => nil})
      lambda { child.belongs_to_relationships.first.rest_path }.should raise_exception(Amfetamine::InvalidPath)
    end
  end

  context "Adding and modifying children" do
    before do
      dummy.children << child
      child.instance_variable_set(:@notsaved, false)

      Child.stub_responses! do |allow|
        allow.get(path:"/dummies/#{dummy.id}/children") { [child] }
        allow.get(path:"/dummies/#{dummy.id}/children/#{child.id}") { child }
        allow.post {}
      end

      Dummy.stub_responses! do |allow|
        allow.get { dummy }
      end
    end

    it "should create a relationship if parent id is passed in params" do
      child2 = Child.new(:title => 'Child2', :dummy_id => dummy.id)
      child2.dummy.should be_a(Amfetamine::Relationship)
    end

    it "should be possible list all children" do
      dummy.children.should include(child)
    end

    it "should be possible to get all children if not in memory" do
      Dummy.cache.flush
      new_dummy = nil
      Dummy.prevent_external_connections! do |r|
        r.get { dummy }
        new_dummy = Dummy.find(dummy.id)
      end

      children = nil
      Dummy.prevent_external_connections! do |r|
        r.get { [child] }
        children = new_dummy.children.all
      end
      children.should include(child)
    end

    it "should be possible to get a single child if not in memory" do
      new_dummy = Dummy.find(dummy.id)
      new_child = new_dummy.children.find(child.id)
      new_child.should == child
    end

    it "should build new child if asked" do
      new_child = dummy.build_child
      new_child.should be_new
      new_child.should be_a(Child)
    end

    it "should create a new child if asked" do
      Child.prevent_external_connections! do |allow|
        allow.post(:code => 201) { child }
        allow.get { [child] }

        new_child = dummy.create_child(child.attributes)
        new_child.should_not be_new
        new_child.should be_cached

        dummy.children.should include(new_child)
        Dummy.cache.flush
        dummy.children.should include(new_child)
      end
    end
  end

  context "has_many_resources relationship using `class_name` option" do

    let(:teacher) { build :teacher }

    specify { teacher.pupils.should be_a(Amfetamine::Relationship) }

    context "generates correct paths for fetching pupils" do
      specify { teacher.pupils.full_path.should eql("teachers/#{ teacher.id }/pupils") }
      specify { teacher.pupils.rest_path.should eql("/teachers/#{ teacher.id }/pupils") }
      specify { teacher.pupils.find_path(1).should eql("/teachers/#{ teacher.id }/pupils/1") }
    end

    it "builds new pupils" do
      new_pupil = teacher.build_pupil
      new_pupil.should be_new
      new_pupil.should be_a(Child)
    end

    it "creates new pupils" do
      attrs = { id: 1, title: 'Pupil' }
      pupil = teacher.build_pupil(attrs)

      Child.prevent_external_connections! do |allow|
        allow.post(:code => 201) { pupil }
        allow.get { [pupil] }

        new_pupil = teacher.create_pupil(attrs)
        new_pupil.should_not be_new
        new_pupil.should be_cached
        new_pupil.should be_a(Child)
      end
    end

  end

  context "belongs_to_resource relationship using `class_name` option" do

    let(:infant) { build :infant }

    specify { infant.parent.should be_a(Amfetamine::Relationship) }

    context "generates correct paths for fetching parent" do
      before do
        dummy.children << infant
      end

      specify { infant.parent.full_path.should eql("parents/#{ dummy.id }/infants") }
      specify { infant.parent.rest_path.should eql("/parents/#{ dummy.id }/infants") }
      specify { infant.parent.find_path(1).should eql("/parents/#{ dummy.id }/infants/1") }
    end

  end

  context "multiple has_many_resources relationships" do

    let(:teacher) { build :teacher }
    let!(:pupil) { teacher.build_pupil }
    let!(:student) { teacher.build_student }

    specify { pupil.should be_a(Child) }
    specify { student.should be_a(Student) }
    specify { teacher.pupils.rest_path.should eql("/teachers/#{ teacher.id }/pupils") }
    specify { teacher.students.rest_path.should eql("/teachers/#{ teacher.id }/students") }


  end

end
