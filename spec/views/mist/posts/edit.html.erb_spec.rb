require 'spec_helper'

describe "mist/posts/edit" do
  before(:each) do
    @post = assign(:post, create(:post))
  end

  it "renders the edit post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => mist_posts_path(@post), :method => "post" do
    end
  end
end
