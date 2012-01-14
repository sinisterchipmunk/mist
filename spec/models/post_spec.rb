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
  
  describe "new valid record" do
    subject { build :post }
    
    describe "after saving" do
      before { subject.save! }
      
      it "should have created a content file" do
        File.should be_file(subject.content_path)
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
        @old_content_path = subject.content_path
        subject.title = "changed"
        subject.save!
      end
      
      it "should create a commit" do
        Mist.log.size.should == 2
      end
      
      it "should have changed the content path" do
        @old_content_path.should_not == subject.content_path
      end
      
      it "should have removed the old content path" do
        File.should_not exist(@old_content_path)
      end
      
      it "should hvae created a new content path" do
        File.should be_file(subject.content_path)
      end
    end
    
    describe "changing its subject and its content simultaneously" do
      before do
        @old_content_path = subject.content_path
        subject.title = "changed"
        subject.content = "changed"
        subject.save!
      end
      
      it "should create a commit" do
        Mist.log.size.should == 2
      end
      
      it "should have changed the content path" do
        @old_content_path.should_not == subject.content_path
      end
      
      it "should have removed the old content path" do
        File.should_not exist(@old_content_path)
      end
      
      it "should have created a new content path" do
        File.should be_file(subject.content_path)
      end

      it "should load the new content in a separate query" do
        Post.find(subject.id).content.should == "changed"
      end
    end
  end
end
