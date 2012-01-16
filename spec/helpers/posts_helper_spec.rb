require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the PostsHelper. For example:
#
# describe PostsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe PostsHelper do
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
