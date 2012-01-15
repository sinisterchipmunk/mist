require 'spec_helper'

describe Post do
  describe "validation" do
    before { subject.valid? }
    
    it "should require title" do
      subject.errors[:title].should include("can't be blank")
    end
    
    it "should require content" do
      subject.errors[:content].should include("can't be blank")
    end
    
    it "should enforce uniqueness of title" do
      create :post
      post = build :post
      post.valid?
      post.errors[:title].should include("has already been taken")
    end
  end
  
  describe "creation" do
    it "should return the post" do
      Post.create!(attributes_for :post).should be_kind_of(Post)
    end
    
    it "should not be a new record" do
      Post.create!(attributes_for :post).should_not be_new_record
    end
  end
  
  describe "new valid record" do
    subject { build :post }
    
    it { should_not be_persisted }
    it { should be_new_record }
    it { should be_changed }
    
    describe "after saving" do
      before { subject.save! }
      
      it { should be_persisted }
      it { should_not be_new_record }
      it { should_not be_changed }
      
      it "should increase count" do
        Post.count.should == 1
      end

      it "should have created an attribute file" do
        File.should be_file(subject.path)
      end
      
      it "should have created a commit" do
        Mist.log.size.should == 1
      end
      
      it "should load the content in a separate query" do
        Post.find(subject.id).content.should == subject.content
      end
    end
  end
  
  describe "an existing record" do
    subject { create :post }
    
    describe "destroying" do
      before { subject.destroy }
      
      it "should not be found" do
        Post.find(subject.id).should be_nil
      end
      
      it "should produce a commit" do
        Mist.log.size.should == 2
      end
      
      it "should reduce count" do
        Post.count.should == 0
      end
    end
    
    describe "changing its content" do
      before { subject.content = "changed"; subject.save! }
      
      it "should create a commit" do
        Mist.log.size.should == 2
      end
      
      it "should load the new content in a separate query" do
        Post.find(subject.id).content.should == "changed"
      end
    end
    
    describe "changing its subject" do
      before do
        @old_path = subject.path
        subject.title = "changed"
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
      
      it "should hvae created a new content path" do
        File.should be_file(subject.path)
      end
    end
    
    describe "changing its subject and its content simultaneously" do
      before do
        @old_path = subject.path
        subject.title = "changed"
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
        Post.find(subject.id).content.should == "changed"
      end
    end
  end
  
  describe "active model lint tests" do
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests
  
    def model
      @model ||= Class.new(Mist::GitModel) do
        def self.name
          "TestModel"
        end
      end.new
    end
  
    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end
  end
end
