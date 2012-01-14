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
      
      it "should load the content in a new record" do
        Post.find(subject.id).content.should == subject.content
      end
    end
  end
end
