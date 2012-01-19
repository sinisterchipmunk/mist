require 'spec_helper'

describe Mist::PostsHelper do
  describe "with 7 posts" do
    before do
      %w(one two three four five six seven).each do |title|
        Mist::Post.create!(:title => title, :content => "#{title} content", :published => true)
      end
    end
    
    it "should only return 5 posts" do
      helper.recent_posts.should have(5).items
    end
    
    it "should include the last 5 posts" do
      helper.recent_posts[0].title.should == "seven"
      helper.recent_posts[1].title.should == "six"
      helper.recent_posts[2].title.should == "five"
      helper.recent_posts[3].title.should == "four"
      helper.recent_posts[4].title.should == "three"
    end
  end
  
  describe "if authorized" do
    before { Mist.authorize(:create_post, :edit_post) { true } }
    
    it "should produce a single authorized link" do
      link = helper.authorized_link :create_post, "Caption", "/"
      link.should == helper.link_to("Caption", "/")
    end
    
    it "should produce multiple joined authorized links" do
      links = helper.authorized_links 'sep', [:create_post, "Create", "/"], [:edit_post, "Edit", "/"]
      links.should == [helper.link_to("Create", "/"), helper.link_to("Edit", "/")].join('sep')
    end
  end
  
  describe "if not authorized" do
    it "should produce no authorized link" do
      link = helper.authorized_link :create_post, "Caption", "/"
      link.should == ""
    end
    
    it "should not produce multiple joined authorized links" do
      links = helper.authorized_links 'sep', [:create_post, "Caption", "/"], [:create_post, "Caption", "/"]
      links.should == ""
    end
  end
  
  describe "if partially authorized" do
    before { Mist.authorize(:create_post) { true } }
    
    it "should produce a single authorized link" do
      link = helper.authorized_link :create_post, "Caption", "/"
      link.should == helper.link_to("Caption", "/")
    end
    
    it "should produce two joined authorized links instead of three" do
      links = helper.authorized_links 'sep', [:create_post, "One", "/"], [:edit_post, "Two", "/"],
                                             [:create_post, "Three", "/"]
      links.should == [helper.link_to("One", "/"), helper.link_to("Three", "/")].join('sep')
    end
  end
end
