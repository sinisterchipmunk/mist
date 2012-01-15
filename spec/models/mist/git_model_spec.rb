require 'spec_helper'
require 'mist/git_model'

describe Mist::GitModel do
  let(:model_class) { Class.new(Mist::GitModel) { def self.name; "TestModel"; end } }
  subject { model_class.new }
  
  it "should underscore and pluralize #table_name" do
    subject.table_name.should == 'test_models'
  end
  
  it "should not be changed" do
    # applying defaults should not be considered a change to a new record
    subject.should_not be_changed
  end

  describe "validation" do
    it "should not require id" do
      subject.valid?
      subject.errors[:id].should_not include("can't be blank")
    end
    
    describe "with an id" do
      before { subject.id = 1 }
      
      it "should enforce uniqueness of id" do
        subject.save!

        other = model_class.new(:id => 1)
        other.valid?
        other.errors[:id].should include("has already been taken")
      end
    end
  end
  
  describe "creation" do
    subject { model_class.create! }
    
    it "should return the model" do
      subject.should be_kind_of(model_class)
    end
    
    it "should not be a new record" do
      subject.should_not be_new_record
    end
    
    it "should have an id" do
      subject.id.should_not be_blank
    end
    
    it "should find it by its id" do
      model_class.find(subject.id).should == subject
    end
  end
  
  describe "new default record" do
    it { should_not be_persisted }
    it { should be_new_record }
    it { should_not be_changed }
    
    describe "after saving" do
      before { subject.save! }
      
      it { should be_persisted }
      it { should_not be_new_record }
      it { should_not be_changed }
      
      it "should increase count" do
        model_class.count.should == 1
      end

      it "should have created a file record" do
        File.should be_file(subject.path)
      end
      
      it "should have created a commit" do
        Mist.log.size.should == 1
      end
      
      it "should load the content in a separate query" do
        model_class.find(subject.id).id.should == subject.id
      end
    end
  end
  
  describe "an existing record" do
    subject { model_class.create! }
    
    describe "destroying" do
      before { subject.destroy }
      
      it "should not be found" do
        model_class.find(subject.id).should be_nil
      end
      
      it "should produce a commit" do
        Mist.log.size.should == 2
      end
      
      it "should reduce count" do
        model_class.count.should == 0
      end
    end
    
    describe "with an attribute" do
      before { model_class.attribute(:content); subject.save! }
      
      describe "changing an attribute" do
        before { subject.content = "changed"; subject.save! }
      
        it "should create a commit" do
          Mist.log.size.should == 2
        end
      
        it "should load the new content in a separate query" do
          model_class.find(subject.id).content.should == "changed"
        end
      end
    
      describe "changing its id and its attribute simultaneously" do
        before do
          @old_path = subject.path
          subject.id = 2
          subject.content = "changed"
          subject.save!
        end
      
        it "should create a commit" do
          Mist.log.size.should == 2
        end
      
        it "should have changed the content path" do
          @old_path.should_not == subject.path
        end
      
        it "should have removed the old content path" do
          File.should_not exist(@old_path)
        end
      
        it "should have created a new content path" do
          File.should be_file(subject.path)
        end

        it "should load the new content in a separate query" do
          model_class.find(subject.id).content.should == "changed"
        end
      end
    end
  end
  
  
  describe "active model lint tests" do
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    def model
      subject
    end

    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end
  end
end